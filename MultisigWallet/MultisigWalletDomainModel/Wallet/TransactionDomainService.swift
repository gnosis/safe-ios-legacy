//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class TransactionDomainService {

    public init() {}

    public func removeDraftTransaction(_ id: TransactionID) {
        let repository = DomainRegistry.transactionRepository
        if let transaction = repository.find(id: id), transaction.status == .draft {
            repository.remove(transaction)
        }
    }

    public func newDraftTransaction(token: Address = Token.Ether.address) -> TransactionID {
        return newDraftTransaction(in: DomainRegistry.walletRepository.selectedWallet()!, token: token)
    }

    public func newDraftTransaction(in wallet: Wallet, token: Address = Token.Ether.address) -> TransactionID {
        let repository = DomainRegistry.transactionRepository
        let transaction = Transaction(id: repository.nextID(),
                                      type: .transfer,
                                      accountID: AccountID(tokenID: TokenID(token.value), walletID: wallet.id))
        transaction.change(sender: wallet.address)
        repository.save(transaction)
        return transaction.id
    }

    public func allTransactions() -> [Transaction] {
        let walletID = DomainRegistry.portfolioRepository.portfolio()?.selectedWallet
        let all = DomainRegistry.transactionRepository.all()
        return all
            .filter { tx in
                tx.status != .draft &&
                tx.status != .signing &&
                tx.status != .rejected &&
                tx.accountID.walletID == walletID
            }
            .sorted { lhs, rhs in
                var lDates = lhs.allEventDates.makeIterator()
                var rDates = rhs.allEventDates.makeIterator()
                while true {
                    switch (lDates.next(), rDates.next()) {
                    case (.none, .some):
                        return true
                    case (.some, .none):
                        return false
                    case let (.some(left), .some(right)) where left == right:
                        continue
                    case let (.some(left), .some(right)):
                        return left > right
                    case (.none, .none):
                        if lhs.status == rhs.status {
                            return lhs.id.id < rhs.id.id
                        } else {
                            return lhs.status.rawValue < rhs.status.rawValue
                        }
                    }
                }
        }
    }

    /// Groups transactions by day, in reverse chronologic order, with pending transaction as 1st group.
    public func grouppedTransactions() -> [TransactionGroup] {
        var groups = [TransactionGroup]()
        var pendingGroup = TransactionGroup(type: .pending, date: nil, transactions: [])
        for tx in allTransactions() {
            if tx.status == .pending {
                pendingGroup.transactions.append(tx)
                continue
            }
            precondition(tx.allEventDates.first != nil, "Transaction must be timestamped: \(tx)")
            let txDate = tx.allEventDates.first!.dateForGrouping
            if groups.last?.date != txDate {
                let newGroup = TransactionGroup(type: .processed, date: txDate, transactions: [])
                groups.append(newGroup)
            }
            groups[groups.count - 1].transactions.append(tx)
        }
        return ([pendingGroup] + groups).filter { !$0.transactions.isEmpty }
    }

    // NOTE: due to the nature of blockchain network - it is an unstable network of nodes - reorgs, different
    // blocks mined at the same time with the same transactions - it may be the case that information about
    // transaction migh change - its blockHash, the block's timestamp, and other. This updating of the
    // information from the blockchain is going to be replaced with API calls for fetching transaction information
    // from the backend. Meanwhile, we try to get the information and use it as is, if it is available.
    public func updatePendingTransactions() throws {
        let transactions = DomainRegistry.transactionRepository.all().filter { $0.status == .pending }
        let nodeService = DomainRegistry.ethereumNodeService
        var hasUpdates = false
        for tx in transactions {
            guard let hash = tx.transactionHash else {
                assertionFailure("Transaction must have a blockchain hash: \(tx)")
                throw TransactionDomainServiceError.transactionHashNotSet("Pending transaction missing hash: \(tx)")
            }
            guard let receipt = try nodeService.eth_getTransactionReceipt(transaction: hash) else {
                // still pending, no receipt found
                continue
            }
            if receipt.status == .success {
                tx.succeed()
            } else {
                tx.fail()
            }
            if let block = try nodeService.eth_getBlockByHash(hash: receipt.blockHash) {
                timestamp(transaction: tx, from: block)
            }
            DomainRegistry.transactionRepository.save(tx)
            hasUpdates = true
        }
        if hasUpdates {
            DomainRegistry.eventPublisher.publish(TransactionStatusUpdated())
        }
    }

    /// Remove temporary transactions from transaction repository.
    public func cleanUpStaleTransactions() {
        let cleanUpStatuses = [TransactionStatus.Code.draft, .signing]
        let toDelete = DomainRegistry.transactionRepository.all().filter { cleanUpStatuses.contains($0.status) }
        for tx in toDelete {
            DomainRegistry.transactionRepository.remove(tx)
        }
    }

    private func timestamp(transaction: Transaction, from block: EthBlock) {
        transaction.timestampProcessed(at: block.timestamp).timestampUpdated(at: Date())
        DomainRegistry.transactionRepository.save(transaction)
    }

    public func isDangerous(_ transactionID: TransactionID) -> Bool {
        guard let transaction = DomainRegistry.transactionRepository.find(id: transactionID),
            let wallet = DomainRegistry.walletRepository.find(id: transaction.accountID.walletID),
            let walletAddress = wallet.address else { return false }

        if let subtransactions = batchedTransactions(from: transaction, walletID: wallet.id),
            subtransactions.allSatisfy({ !$0.isDangerous(walletAddress: walletAddress) }) {
            return false
        }

        return transaction.isDangerous(walletAddress: walletAddress)
    }

    public func batchedTransactions(in transactionID: TransactionID) -> [Transaction]? {
        guard let transaction = DomainRegistry.transactionRepository.find(id: transactionID),
            let wallet = DomainRegistry.walletRepository.find(id: transaction.accountID.walletID),
            transaction.type == .transfer else { return nil }
        return batchedTransactions(from: transaction, walletID: wallet.id)
    }

    private func batchedTransactions(from transaction: Transaction, walletID: WalletID) -> [Transaction]? {
        let isMultiSend = transaction.operation == .delegateCall &&
            transaction.recipient == DomainRegistry.safeContractMetadataRepository.multiSendContractAddress

        if isMultiSend,
            let data = transaction.data,
            let arguments = MultiSendContractProxy(transaction.recipient!).decodeMultiSendArguments(from: data) {
            return arguments.map { self.transaction(from: $0, in: walletID) }
        }
        return nil
    }

    private func transaction(from multiSend: MultiSendTransaction, in walletID: WalletID) -> Transaction {
        let result = Transaction(id: DomainRegistry.transactionRepository.nextID(),
                                 type: .transfer,
                                 accountID: AccountID(tokenID: Token.Ether.id, walletID: walletID))
        let formattedRecipient = DomainRegistry.encryptionService.address(from: multiSend.to.value)!

        result.change(recipient: formattedRecipient)
            .change(data: multiSend.data)
            .change(operation: WalletOperation(rawValue: multiSend.operation.rawValue))

        enhanceWithERC20Data(transaction: result, to: formattedRecipient, data: multiSend.data)

        return result
    }

    public func enhanceWithERC20Data(transaction: Transaction, to address: Address, data: Data) {
        let tokenProxy = ERC20TokenContractProxy(address)
        if let erc20Transfer = tokenProxy.decodedTransfer(from: data) {
            let amountToken = self.token(for: address)
            transaction
                .change(recipient: erc20Transfer.recipient)
                .change(amount: TokenAmount(amount: erc20Transfer.amount, token: amountToken))
        }
    }

    public func token(for address: Address) -> Token {
        let tokenProxy = ERC20TokenContractProxy(address)
        if let token = WalletDomainService.token(id: address.value) {
            return token
        } else {
            let token: Token
            if let name = try? tokenProxy.name(),
                let code = try? tokenProxy.symbol(),
                let decimals = try? tokenProxy.decimals() {
                token = Token(code: code, name: name, decimals: decimals, address: address, logoUrl: "")
            } else {
                token = Token(code: "---", name: address.value, decimals: 18, address: address, logoUrl: "")
            }
            try? DomainRegistry.accountUpdateService.updateAccountBalance(token: token)
            return token
        }
    }

}

public class TransactionStatusUpdated: DomainEvent {}

fileprivate extension Transaction {

    var allEventDates: [Date] {
        return [processedDate, submittedDate, rejectedDate, updatedDate, createdDate].compactMap { $0 }
    }

}

public extension Date {

    var dateForGrouping: Date {
        let calendar = Calendar.autoupdatingCurrent
        return calendar.date(from: calendar.dateComponents([.era, .year, .month, .day], from: self))!
    }

}

fileprivate extension Date {

    var isToday: Bool {
        return Calendar.autoupdatingCurrent.isDateInToday(self)
    }

    var isInTheFuture: Bool {
        return self > Date()
    }

}

public enum TransactionDomainServiceError: Error {

    case transactionHashNotSet(String)
    case transactionReceiptNotFound(String)

}
