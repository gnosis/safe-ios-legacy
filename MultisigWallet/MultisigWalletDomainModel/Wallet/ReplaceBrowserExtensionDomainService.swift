//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public enum ReplaceBrowserExtensionDomainServiceError: Error {
    case insufficientBalance
    case browserExtensionNotConnected
    case browserExtensionAlreadyExists
    case recoveryPhraseInvalid
    case recoveryPhraseHasNoOwnership
}

open class ReplaceBrowserExtensionDomainService: Assertable {

    open var isAvailable: Bool {
        guard let wallet = self.wallet else { return false }
        return wallet.owner(role: .browserExtension) != nil
    }

    public var ownerContractProxy: SafeOwnerManagerContractProxy?

    private var wallet: Wallet? {
        return DomainRegistry.walletRepository.selectedWallet()
    }

    private var requiredWallet: Wallet {
        return wallet!
    }

    private var repository: TransactionRepository {
        return DomainRegistry.transactionRepository
    }

    private var contractProxy: SafeOwnerManagerContractProxy {
        return ownerContractProxy ?? SafeOwnerManagerContractProxy(self.wallet!.address!)
    }

    public init() {}

    // MARK: - Transaction Creation and Validation

    public func createTransaction() -> TransactionID {
        let tx = Transaction(id: repository.nextID(),
                             type: .replaceBrowserExtension,
                             walletID: requiredWallet.id,
                             accountID: AccountID(tokenID: Token.Ether.id, walletID: requiredWallet.id))
        tx.change(amount: .ether(0)).change(sender: requiredWallet.address!)
        repository.save(tx)
        return tx.id
    }

    public func deleteTransaction(id: TransactionID) {
        repository.remove(transaction(id))
    }

    public func addDummyData(to transactionID: TransactionID) {
        let tx = transaction(transactionID)
        tx.change(recipient: wallet!.address!).change(operation: .call).change(data: dummySwapData())
        repository.save(tx)
    }

    func dummySwapData() -> Data {
        var remoteList = OwnerLinkedList()
        if let owners = try? contractProxy.getOwners(), !owners.isEmpty {
            owners.forEach { remoteList.add($0) }
            let toSwap = owners.first!
            let prev = remoteList.addressBefore(toSwap)
            let data = contractProxy.swapOwner(prevOwner: prev, old: toSwap, new: self.wallet!.address!)
            return data
        }
        remoteList.add(.zero)
        return contractProxy.swapOwner(prevOwner: remoteList.addressBefore(.one), old: .zero, new: .zero)
    }

    public func removeDummyData(from transactionID: TransactionID) {
        let tx = transaction(transactionID)
        tx.change(recipient: nil).change(operation: nil).change(data: nil)
        repository.save(tx)
    }

    open func estimateNetworkFee(for transactionID: TransactionID) throws -> TokenAmount {
        let tx = transaction(transactionID)
        let request = estimationRequest(for: tx)
        let response = try DomainRegistry.transactionRelayService.estimateTransaction(request: request)
        let userFacingFee = TokenInt((response.dataGas + response.safeTxGas + response.operationalGas) *
            response.gasPrice)
        let transactionFee = TokenInt((response.dataGas + response.safeTxGas) * response.gasPrice)
        let token = Token.Ether
        tx.change(fee: TokenAmount(amount: transactionFee, token: token))
        let estimate = TransactionFeeEstimate(gas: response.safeTxGas,
                                              dataGas: response.dataGas,
                                              operationalGas: response.operationalGas,
                                              gasPrice: TokenAmount(amount: TokenInt(response.gasPrice), token: token))
        tx.change(feeEstimate: estimate)
          .change(nonce: String(response.nextNonce))
        repository.save(tx)
        return .ether(userFacingFee)
    }

    private func estimationRequest(for tx: Transaction) -> EstimateTransactionRequest {
        return .init(safe: tx.sender!,
                     to: tx.ethTo,
                     value: String(tx.ethValue),
                     data: tx.ethData,
                     operation: tx.operation!)
    }

    public func accountBalance(for transactionID: TransactionID) -> TokenAmount {
        let tx = transaction(transactionID)
        let account = DomainRegistry.accountRepository.find(id: tx.accountID)!
        let balance = account.balance ?? 0
        return .ether(balance)
    }

    public func resultingBalance(for transactionID: TransactionID, change amount: TokenAmount) -> TokenAmount {
        let balance = accountBalance(for: transactionID)
        let newBalance = TokenAmount(amount: balance.amount + amount.amount, token: balance.token)
        return newBalance
    }

    public func validate(transactionID: TransactionID) throws {
        let tx = transaction(transactionID)
        precondition(tx.fee != nil, "fee must be set during estimation")
        precondition(tx.feeEstimate != nil, "fee estimate must be set during estimation")
        let totalFeeAmount = -TokenInt(tx.feeEstimate!.dataGas + tx.feeEstimate!.gas + tx.feeEstimate!.operationalGas) *
            tx.feeEstimate!.gasPrice.amount
        let totalFee = TokenAmount(amount: totalFeeAmount, token: tx.feeEstimate!.gasPrice.token)
        try assertTrue(resultingBalance(for: transactionID, change: totalFee).amount >= 0,
                       ReplaceBrowserExtensionDomainServiceError.insufficientBalance)
        try assertNotNil(requiredWallet.owner(role: .browserExtension) ,
                         ReplaceBrowserExtensionDomainServiceError.browserExtensionNotConnected)
    }

    private func transaction(_ id: TransactionID, file: StaticString = #file, line: UInt = #line) -> Transaction {
        guard let tx = repository.findByID(id) else {
            preconditionFailure("transaction not found \(file):\(line)")
        }
        return tx
    }

    // MARK: - Connection of Browser Extension

    open func validateNewOwnerAddress(_ address: String) throws {
        guard let list = remoteOwnersList(), !list.contains(Address(address)) else {
            throw ReplaceBrowserExtensionDomainServiceError.browserExtensionAlreadyExists
        }
    }

    open func newOwnerAddress(from transactionID: TransactionID) -> String? {
        let tx = self.transaction(transactionID)
        guard let data = tx.data, let arguments = contractProxy.decodeSwapOwnerArguments(from: data) else { return nil }
        return arguments.new.value
    }

    open func update(transaction: TransactionID, newOwnerAddress: String) {
        let tx = self.transaction(transaction)
        tx.change(data: swapOwnerData(with: newOwnerAddress))
        repository.save(tx)
    }

    func swapOwnerData(with newAddress: String) -> Data? {
        let extensionAddress = wallet!.owner(role: .browserExtension)!.address
        guard let linkedList = remoteOwnersList(), linkedList.contains(extensionAddress) else { return nil }
        return contractProxy.swapOwner(prevOwner: linkedList.addressBefore(extensionAddress),
                                       old: extensionAddress,
                                       new: Address(newAddress))
    }

    private func remoteOwnersList() -> OwnerLinkedList? {
        var linkedList = OwnerLinkedList()
        guard let remoteOwners = try? contractProxy.getOwners(), !remoteOwners.isEmpty else { return nil }
        remoteOwners.forEach { linkedList.add($0) }
        return linkedList
    }

    // MARK: - Signing the Transaction

    open func sign(transactionID: TransactionID, with phrase: String) throws {
        guard let eoa = signingEOA(from: phrase) else {
            throw ReplaceBrowserExtensionDomainServiceError.recoveryPhraseInvalid
        }
        guard try isContractOwners(eoa: eoa) else {
            throw ReplaceBrowserExtensionDomainServiceError.recoveryPhraseHasNoOwnership
        }
        let tx = self.transaction(transactionID)
        tx.change(hash: DomainRegistry.encryptionService.hash(of: tx))
        tx.proceed()
        sign(tx: tx, with: eoa.primary)
        sign(tx: tx, with: eoa.derived)
        repository.save(tx)
    }

    private func isContractOwners(eoa: EOAPair) throws -> Bool {
        let contractOwners = try contractProxy.getOwners()
        return contractOwners.contains { $0.value.lowercased() == eoa.primary.address.value.lowercased() } &&
            contractOwners.contains { $0.value.lowercased() == eoa.derived.address.value.lowercased() }
    }

    private func sign(tx: Transaction, with eoa: ExternallyOwnedAccount) {
        let signatureData = DomainRegistry.encryptionService.sign(transaction: tx, privateKey: eoa.privateKey)
        tx.add(signature: Signature(data: signatureData, address: eoa.address))
    }

    typealias EOAPair = (primary: ExternallyOwnedAccount, derived: ExternallyOwnedAccount)

    func signingEOA(from phrase: String) -> EOAPair? {
        guard let primary = DomainRegistry.encryptionService.deriveExternallyOwnedAccount(from: phrase) else {
            return nil
        }
        let derived = DomainRegistry.encryptionService.deriveExternallyOwnedAccount(from: primary, at: 1)
        return (primary, derived)
    }

    // MARK: - Post-processing

    open func postProcess(transactionID: TransactionID) throws {
        guard let tx = repository.findByID(transactionID),
            tx.status == .success || tx.status == .failed,
            let wallet = DomainRegistry.walletRepository.findByID(tx.walletID) else { return }
        guard let newOwner = newOwnerAddress(from: transactionID) else {
            unregisterPostProcessing(for: transactionID)
            return
        }
        if tx.status == .success {
            try replace(newOwner: newOwner, in: wallet)
        } else {
            try DomainRegistry.communicationService.deletePair(walletID: tx.walletID, other: newOwner)
        }
        unregisterPostProcessing(for: transactionID)
    }

    private func replace(newOwner: String, in wallet: Wallet) throws {
        guard let oldOwner = wallet.owner(role: .browserExtension) else { return }
        try DomainRegistry.communicationService.deletePair(walletID: wallet.id, other: oldOwner.address.value)
        wallet.removeOwner(role: oldOwner.role)
        wallet.addOwner(Owner(address: Address(newOwner), role: oldOwner.role))
        DomainRegistry.walletRepository.save(wallet)
    }

    open func registerPostProcessing(for transactionID: TransactionID, timestamp: Date = Date()) {
        let entry = RBETransactionMonitorEntry(transactionID: transactionID, createdDate: timestamp)
        DomainRegistry.transactionMonitorRepository.save(entry)
    }

    open func unregisterPostProcessing(for transactionID: TransactionID) {
        if let entry = DomainRegistry.transactionMonitorRepository.find(id: transactionID) {
            DomainRegistry.transactionMonitorRepository.remove(entry)
        }
    }

    open func postProcessTransactions() throws {
        let allEntries = DomainRegistry.transactionMonitorRepository.findAll().sorted {
            $0.createdDate < $1.createdDate
        }
        for entry in allEntries {
            try postProcess(transactionID: entry.transactionID)
        }
    }

    private static var doNotCleanUpStatuses = [TransactionStatus.Code.rejected, .success, .failed, .pending]

    open func cleanUpStaleTransactions() {
        let toDelete = DomainRegistry.transactionRepository.findAll().filter {
            $0.type == .replaceBrowserExtension &&
            !ReplaceBrowserExtensionDomainService.doNotCleanUpStatuses.contains($0.status)
        }
        for tx in toDelete {
            DomainRegistry.transactionRepository.remove(tx)
        }
    }

}
