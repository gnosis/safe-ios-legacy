//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public enum ReplaceTwoFADomainServiceError: Error {
    case insufficientBalance
    case twoFANotConnected
    case twoFAAlreadyExists
    case recoveryPhraseInvalid
    case recoveryPhraseHasNoOwnership
}

// TODO: create a common base class
open class ReplaceTwoFADomainService: Assertable {

    open var isAvailable: Bool {
        guard let wallet = self.wallet else { return false }
        return wallet.isReadyToUse && wallet.hasAuthenticator && wallet.type == .personal
    }

    public var ownerContractProxy: SafeOwnerManagerContractProxy?

    var wallet: Wallet? {
        return DomainRegistry.walletRepository.selectedWallet()
    }

    var requiredWallet: Wallet {
        return wallet!
    }

    var repository: TransactionRepository {
        return DomainRegistry.transactionRepository
    }

    var contractProxy: SafeOwnerManagerContractProxy {
        return ownerContractProxy ?? SafeOwnerManagerContractProxy(self.wallet!.address)
    }

    public init() {}

    // MARK: - Transaction Creation and Validation

    public func createTransaction() -> TransactionID {
        let token = requiredWallet.feePaymentTokenAddress ?? Token.Ether.address
        let tx = Transaction(id: repository.nextID(),
                             type: .replaceTwoFAWithAuthenticator,
                             accountID: AccountID(tokenID: TokenID(token.value), walletID: requiredWallet.id))
        tx.change(amount: .ether(0)).change(sender: requiredWallet.address)
        repository.save(tx)
        return tx.id
    }

    public func updateTransaction(_ transactionID: TransactionID, with type: TransactionType) {
        let tx = transaction(transactionID)
        tx.change(type: type)
        repository.save(tx)
    }

    public func deleteTransaction(id: TransactionID) {
        repository.remove(transaction(id))
    }

    public func addDummyData(to transactionID: TransactionID) {
        let tx = transaction(transactionID)
        tx.change(recipient: requiredWallet.address)
            .change(operation: .call)
            .change(data: dummyTransactionData())
        repository.save(tx)
    }

    func dummyTransactionData() -> Data {
        if let linkedList = remoteOwnersList(), let toSwap = linkedList.firstAddress() {
            return contractProxy.swapOwner(prevOwner: linkedList.addressBefore(toSwap),
                                           old: toSwap,
                                           new: requiredWallet.address)
        }
        var remoteList = OwnerLinkedList()
        remoteList.add(.zero)
        return contractProxy.swapOwner(prevOwner: remoteList.addressBefore(.zero), old: .zero, new: .zero)
    }

    open func stepBackToDraft(_ transactionID: TransactionID) {
        let tx = DomainRegistry.transactionRepository.find(id: transactionID)!
        if tx.status == .signing {
            tx.stepBack()
            DomainRegistry.transactionRepository.save(tx)
        }
    }

    open func estimateNetworkFee(for transactionID: TransactionID) throws -> TokenAmount {
        let tx = transaction(transactionID)
        let request = estimationRequest(for: tx)
        let response = try DomainRegistry.transactionRelayService.estimateTransaction(request: request)
        let feeToken = DomainRegistry.tokenListItemRepository.find(id: TokenID(response.gasToken))?.token ?? Token.Ether
        let estimate = TransactionFeeEstimate(gas: response.safeTxGas.value,
                                              dataGas: response.baseGas.value,
                                              operationalGas: response.operationalGas.value,
                                              gasPrice: TokenAmount(amount: response.gasPrice.value,
                                                                    token: feeToken))
        tx.change(fee: estimate.totalSubmittedToBlockchain)
            .change(feeEstimate: estimate)
            .change(nonce: String(response.nextNonce))
        repository.save(tx)
        return estimate.totalDisplayedToUser
    }

    private func estimationRequest(for tx: Transaction) -> EstimateTransactionRequest {
        return .init(safe: tx.sender!,
                     to: tx.ethTo,
                     value: String(tx.ethValue),
                     data: tx.ethData,
                     operation: tx.operation!,
                     gasToken: requiredWallet.feePaymentTokenAddress?.value)
    }

    public func accountBalance(for transactionID: TransactionID) -> TokenAmount {
        let tx = transaction(transactionID)
        guard let account = DomainRegistry.accountRepository.find(id: tx.accountID) else {
            return TokenAmount(amount: 0, token: .Ether)
        }
        let balance = account.balance ?? 0
        let token = DomainRegistry.tokenListItemRepository.find(id: account.id.tokenID)?.token ?? Token.Ether
        return TokenAmount(amount: balance, token: token)
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
                       ReplaceTwoFADomainServiceError.insufficientBalance)
        try validateOwners()
    }

    func validateOwners() throws {
        try assertTrue(requiredWallet.hasAuthenticator, ReplaceTwoFADomainServiceError.twoFANotConnected)
    }

    public func transaction(_ id: TransactionID, file: StaticString = #file, line: UInt = #line) -> Transaction {
        guard let tx = repository.find(id: id) else {
            preconditionFailure("transaction not found \(file):\(line)")
        }
        return tx
    }

    // MARK: - Connection of Browser Extension

    open func validateNewOwnerAddress(_ address: String) throws {
        guard let list = remoteOwnersList(), !list.contains(Address(address)) else {
            throw ReplaceTwoFADomainServiceError.twoFAAlreadyExists
        }
    }

    open func newOwnerAddress(from transactionID: TransactionID) -> String? {
        let tx = self.transaction(transactionID)
        guard let data = tx.data, let arguments = contractProxy.decodeSwapOwnerArguments(from: data) else { return nil }
        return arguments.new.value
    }

    open func update(transaction: TransactionID, newOwnerAddress: String) {
        stepBackToDraft(transaction)
        let tx = self.transaction(transaction)
        tx.change(data: realTransactionData(with: newOwnerAddress))
        repository.save(tx)
    }

    func realTransactionData(with newAddress: String) -> Data? {
        let ownerAddress = requiredWallet.twoFAOwner!.address
        guard let linkedList = remoteOwnersList(), linkedList.contains(ownerAddress) else { return nil }
        return contractProxy.swapOwner(prevOwner: linkedList.addressBefore(ownerAddress),
                                       old: ownerAddress,
                                       new: Address(newAddress))
    }

    func remoteOwnersList() -> OwnerLinkedList? {
        var linkedList = OwnerLinkedList()
        guard let remoteOwners = try? contractProxy.getOwners(), !remoteOwners.isEmpty else { return nil }
        remoteOwners.forEach { linkedList.add($0) }
        return linkedList
    }

    // MARK: - Signing the Transaction

    public func updateHash(transactionID: TransactionID) {
        let tx = self.transaction(transactionID)
        tx.change(hash: DomainRegistry.encryptionService.hash(of: tx))
        repository.save(tx)
    }

    open func sign(transactionID: TransactionID, with phrase: String) throws {
        guard let eoa = signingEOA(from: phrase) else {
            throw ReplaceTwoFADomainServiceError.recoveryPhraseInvalid
        }
        guard try isContractOwners(eoa: eoa) else {
            throw ReplaceTwoFADomainServiceError.recoveryPhraseHasNoOwnership
        }
        updateHash(transactionID: transactionID)
        let tx = self.transaction(transactionID)
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

    var postProcessTypes: [TransactionType] {
        return [.replaceTwoFAWithAuthenticator, .replaceTwoFAWithStatusKeycard]
    }

    open func postProcess(transactionID: TransactionID) throws {
        guard let tx = repository.find(id: transactionID),
            postProcessTypes.contains(tx.type),
            tx.status == .success || tx.status == .failed,
            let wallet = DomainRegistry.walletRepository.find(id: tx.accountID.walletID) else { return }
        guard let newOwner = newOwnerAddress(from: transactionID) else {
            unregisterPostProcessing(for: transactionID)
            return
        }
        if tx.status == .success {
            try processSuccess(tx: tx, with: newOwner, in: wallet)
        } else {
            try processFailure(tx: tx, walletID: tx.accountID.walletID, newOwnerAddress: newOwner)
        }
        unregisterPostProcessing(for: transactionID)
    }

    func processSuccess(tx: Transaction, with newOwner: String, in wallet: Wallet) throws {
        try removeOldTwoFAOwner(from: wallet)
        let role = tx.type.correspondingOwnerRole!
        add(newOwner: newOwner, role: role, to: wallet)
        try? DomainRegistry.communicationService.notifyWalletCreatedIfNeeded(walletID: wallet.id)
    }

    func processFailure(tx: Transaction, walletID: WalletID, newOwnerAddress: String) throws {
        if tx.type == .replaceTwoFAWithAuthenticator {
            try DomainRegistry.communicationService.deletePair(walletID: walletID, other: newOwnerAddress)
        }
    }

    func removeOldTwoFAOwner(from wallet: Wallet) throws {
        guard let oldOwner = wallet.twoFAOwner else { return }
        if oldOwner.role == .browserExtension {
            try DomainRegistry.communicationService.deletePair(walletID: wallet.id, other: oldOwner.address.value)
        }
        wallet.removeOwner(role: oldOwner.role)
    }

    func add(newOwner: String, role: OwnerRole, to wallet: Wallet) {
        let formattedAddress = DomainRegistry.encryptionService.address(from: newOwner) ?? Address(newOwner)
        wallet.addOwner(Owner(address: formattedAddress, role: role))
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

}
