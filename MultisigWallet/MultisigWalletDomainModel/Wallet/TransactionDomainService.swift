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

    public func prepareMultisigTransaction(_ tx: Transaction) {
        if tx.hash != nil  { return } // if tx hash exists then this multisig transaction was already been approved before
                                      //  by us or some other owner

        let multisigWallet = DomainRegistry.walletRepository.find(id: tx.accountID.walletID)!

        let proxy = GnosisSafeContractProxy(multisigWallet.address)
        let safeTxGas = proxy.requiredTxGas(to: tx.ethTo,
                                            value: tx.ethValue,
                                            data: Data(hex: tx.ethData),
                                            operation: tx.operation ?? .call) + 10000

        // feeEstimate = 0-s: gasPrice = 0, operationalGas = 0, dataGas = 0, gas = 0, Ether token
        let fee = TransactionFeeEstimate(gas: safeTxGas, dataGas: 0, operationalGas: 0, gasPrice: .ether(0))
        tx.change(feeEstimate: fee).change(fee: fee.totalSubmittedToBlockchain)

        // operation = call
        tx.change(operation: .call)

        // nonce = get latest transaction nonce (tx service -> latest tx -> nonce)
        //    get max nonce from all transactions in the wallet
        if let contractNonce = try? Int(SafeOwnerManagerContractProxy(multisigWallet.address).nonce()) {
            tx.change(nonce: String(contractNonce))
        } else {
            let maxNonce = DomainRegistry.transactionRepository.find(wallet: multisigWallet.id).filter {
                $0.status == .success
            }.compactMap {
                $0.nonce

            }.map { Int($0)! }.max() ?? -1 // -1 so that first nonce would be '0'

            let nextNonce = maxNonce + 1
            tx.change(nonce: String(nextNonce))
        }

        // hash = service.hash()
        assert(tx.sender != nil)
        assert(tx.amount != nil)
        assert(tx.operation != nil)
        assert(tx.feeEstimate != nil)
        assert(tx.nonce != nil)

        let hash = DomainRegistry.encryptionService.hash(of: tx)
        tx.change(hash: hash)

        DomainRegistry.transactionRepository.save(tx)
    }

    public func createApprovalTransaction(in personalWallet: Wallet, for multisigTransactionID: TransactionID) -> TransactionID {
        let multisigTransaction = DomainRegistry.transactionRepository.find(id: multisigTransactionID)!
        let multisigWallet = DomainRegistry.walletRepository.find(id: multisigTransaction.accountID.walletID)!

        let personalTxID = newDraftTransaction(in: personalWallet)
        let personalTx = DomainRegistry.transactionRepository.find(id: personalTxID)!

        let multisigContract = GnosisSafeContractProxy(multisigWallet.address!)
        let approveHashData = multisigContract.approveHash(multisigTransaction.hash!)

        // recipient = multisig
        personalTx.change(recipient: multisigWallet.address!)
            // amount = 0
            // token = ether
            .change(amount: .ether(0))
        // data = approveHash(multisigTx.hash)
            .change(data: approveHashData)

        DomainRegistry.transactionRepository.save(personalTx)
        return personalTx.id
    }

    public func createExecuteTransaction(from personalWallet: Wallet, for multisigTransactionID: TransactionID) -> TransactionID {
        let multisigTx = DomainRegistry.transactionRepository.find(id: multisigTransactionID)!
        let multisigWallet = DomainRegistry.walletRepository.find(id: multisigTx.accountID.walletID)!

        let personalTxID = newDraftTransaction(in: personalWallet)
        let personalTx = DomainRegistry.transactionRepository.find(id: personalTxID)!

        let multisigContract = GnosisSafeContractProxy(multisigWallet.address!)
        let executeTransactionData = multisigContract.executeTransaction(
            to: multisigTx.ethTo,
            value: multisigTx.ethValue,
            data: Data(hex: multisigTx.ethData),
            operation: multisigTx.operation ?? .call,
            safeTxGas: multisigTx.feeEstimate?.gas ?? 0,
            baseGas: multisigTx.feeEstimate?.dataGas ?? 0,
            gasPrice: multisigTx.feeEstimate?.gasPrice.amount ?? 0,
            gasToken: multisigTx.feeEstimate?.gasPrice.token.address ?? .zero,
            refundReceiver: .zero,
            signatures: multisigTx.encodedSignatures ?? Data()
        )

        // recipient = multisig
        personalTx.change(recipient: multisigWallet.address!)
            // amount = 0
            // token = ether
            .change(amount: .ether(0))
        // data = executeTransaction()
            .change(data: executeTransactionData)

        DomainRegistry.transactionRepository.save(personalTx)
        return personalTx.id
    }



    public func allTransactions() -> [Transaction] {
        let walletID = DomainRegistry.portfolioRepository.portfolio()?.selectedWallet
        let all = DomainRegistry.transactionRepository.all()
        return all
            .filter { tx in
                tx.status != .draft &&
                /* tx.status != .signing && */
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
        var signingGroup = TransactionGroup(type: .signing, date: nil, transactions: [])
        var pendingGroup = TransactionGroup(type: .pending, date: nil, transactions: [])

        // if nonce is < contract nonce, then the transaction can be ignored for signing becuase it will fail.
        let wallet = DomainRegistry.walletRepository.selectedWallet()
        let proxy = SafeOwnerManagerContractProxy(wallet!.address)
        let contractNonce = Int((try? proxy.nonce()) ?? 0)

        for tx in allTransactions() {
            if tx.status == .pending {
                pendingGroup.transactions.append(tx)
                continue
            } else if tx.status == .signing {
//                if (Int(tx.nonce ?? "0") ?? 0) > contractNonce {
                    signingGroup.transactions.append(tx)
//                }
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
        return ([signingGroup, pendingGroup] + groups).filter { !$0.transactions.isEmpty }
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
                if let wcTransaction = DomainRegistry.wcProcessingTxRepository.find(transactionID: tx.id) {
                    DomainRegistry.wcProcessingTxRepository.remove(transactionID: tx.id)
                    wcTransaction.completion(.success(hash.value))
                }
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
        let toDelete = DomainRegistry.transactionRepository.all().filter { tx in
            // for personal wallets, we'll remove both drafts and signing
            if let wallet = DomainRegistry.walletRepository.find(id: tx.accountID.walletID) {
                if wallet.type == .personal && (tx.status == .draft || tx.status == .signing) ||
                    wallet.type == .multisig && (tx.status == .draft) {
                    return true
                }
            }
            return false
        }
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
        // if transaction is multiSend, it'll be dangerous
        return transaction.isDangerous(walletAddress: walletAddress)
    }

    public func batchedTransactions(in transactionID: TransactionID) -> [Transaction]? {
        guard let transaction = DomainRegistry.transactionRepository.find(id: transactionID),
            let wallet = DomainRegistry.walletRepository.find(id: transaction.accountID.walletID) else { return nil }
        return batchedTransactions(from: transaction, walletID: wallet.id)
    }

    private func batchedTransactions(from transaction: Transaction, walletID: WalletID) -> [Transaction]? {
        guard isMultiSend(transaction),
            let recipient = transaction.recipient,
            let data = transaction.data,
            let arguments = MultiSendContractProxy(recipient).decodeMultiSendArguments(from: data) else { return nil }
        return arguments.map {
            let tx = subTransaction(from: $0, in: walletID)
            tx.timestampCreated(at: transaction.createdDate)
            tx.timestampUpdated(at: transaction.updatedDate)
            if let date = transaction.rejectedDate {
                tx.timestampRejected(at: date)
            }
            if let date = transaction.processedDate {
                tx.timestampProcessed(at: date)
            }
            if let date = transaction.submittedDate {
                tx.timestampSubmitted(at: date)
            }
            tx.change(status: transaction.status)
            return tx
        }
    }

    private func isMultiSend(_ transaction: Transaction) -> Bool {
        transaction.type == .batched &&
        transaction.operation == .delegateCall &&
        transaction.data != nil &&
        transaction.recipient != nil &&
        MultiSendContractProxy.isMultiSend(transaction.recipient!)
    }

    private func subTransaction(from multiSend: MultiSendTransaction, in walletID: WalletID) -> Transaction {
        let result = Transaction(id: DomainRegistry.transactionRepository.nextID(),
                                 type: .transfer,
                                 accountID: AccountID(tokenID: Token.Ether.id, walletID: walletID))
        let formattedRecipient = DomainRegistry.encryptionService.address(from: multiSend.to.value)!

        result.change(recipient: formattedRecipient)
            .change(data: multiSend.data)
            .change(operation: WalletOperation(rawValue: multiSend.operation.rawValue))
            .change(amount: TokenAmount.ether(multiSend.value))

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

    var unknownTokensCache = [Address: Token]()

    public func token(for address: Address, shouldUpdateBalanceForUnknownToken: Bool = false) -> Token {
        let tokenProxy = ERC20TokenContractProxy(address)
        if let token = WalletDomainService.token(id: address.value) {
            return token
        } else if let cachedToken = unknownTokensCache[address] {
            return cachedToken
        } else {
            let token: Token
            if let name = try? tokenProxy.name(),
                let code = try? tokenProxy.symbol(),
                let decimals = try? tokenProxy.decimals() {
                token = Token(code: code, name: name, decimals: decimals, address: address, logoUrl: "")
            } else {
                token = Token(code: "---", name: address.value, decimals: 18, address: address, logoUrl: "")
            }
            unknownTokensCache[address] = token
            if shouldUpdateBalanceForUnknownToken {
                try? DomainRegistry.accountUpdateService.updateAccountBalance(token: token)
            }
            return token
        }
    }

    public func syncTransactionsFromTheTransactionService() {
        let syncer = TransactionSyncDomainService()
        let allWallets = DomainRegistry.walletRepository.all().filter { $0.address != nil && $0.isReadyToUse }
        for wallet in allWallets {
            syncer.sync(walletID: wallet.id)
        }
    }

    public func updateTokensFromTheTransactionService() {
        let allWallets = DomainRegistry.walletRepository.all().filter { $0.address != nil && $0.isReadyToUse }
        for wallet in allWallets {
            DomainRegistry.safeTransactionService.updateTokens(safe: wallet.address)
        }
    }

    public func updateWalletInfoFromRelay() {
        let allWallets = DomainRegistry.walletRepository.all().filter { $0.address != nil && $0.isReadyToUse }
        for wallet in allWallets {
            _ = WalletDomainService.updateWalletWithOnchainData(wallet.id.id)

            DomainRegistry.eventPublisher.publish(WalletInfoUpdated())
        }
    }

}

public class WalletInfoUpdated: DomainEvent {}

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
