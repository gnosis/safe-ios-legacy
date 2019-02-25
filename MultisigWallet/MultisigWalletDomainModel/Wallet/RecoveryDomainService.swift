//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import BigInt

public enum RecoveryServiceError: Error {
    case invalidContractAddress
    case recoveryAccountsNotFound
    case recoveryPhraseInvalid
    case unsupportedOwnerCount(String)
    case unsupportedWalletConfiguration(String)
    case failedToChangeOwners
    case failedToChangeConfirmationCount
    case failedToCreateValidTransactionData
    case walletNotFound
    case failedToCreateValidTransaction
    case internalServerError
}

public struct RecoveryDomainServiceConfig {

    var validMasterCopyAddresses: [Address]
    var multiSendContractAddress: Address

    public init(masterCopyAddresses: [String], multiSendAddress: String) {
        validMasterCopyAddresses = masterCopyAddresses.map { Address($0.lowercased()) }
        multiSendContractAddress = Address(multiSendAddress)
    }

}

public class RecoveryDomainService: Assertable {

    public let config: RecoveryDomainServiceConfig

    public init(config: RecoveryDomainServiceConfig) {
        self.config = config
    }

    // MARK: - Creating Draft Wallet

    public func createRecoverDraftWallet() {
        add(wallet: newWallet(with: newOwner()), to: portfolio())
    }

    private func add(wallet: Wallet, to portfolio: Portfolio) {
        portfolio.addWallet(wallet.id)
        portfolio.selectWallet(wallet.id)
        DomainRegistry.portfolioRepository.save(portfolio)
    }

    private func newOwner() -> Address {
        let account = DomainRegistry.encryptionService.generateExternallyOwnedAccount()
        DomainRegistry.externallyOwnedAccountRepository.save(account)
        return account.address
    }

    private func newWallet(with owner: Address) -> Wallet {
        let wallet = Wallet(id: DomainRegistry.walletRepository.nextID(), owner: owner)
        wallet.prepareForRecovery()
        DomainRegistry.walletRepository.save(wallet)
        createAccount(wallet)
        return wallet
    }

    private func createAccount(_ wallet: Wallet) {
        let account = Account(tokenID: Token.Ether.id, walletID: wallet.id)
        DomainRegistry.accountRepository.save(account)
    }

    private func portfolio() -> Portfolio {
        if let result = DomainRegistry.portfolioRepository.portfolio() {
            return result
        }
        let result = Portfolio(id: DomainRegistry.portfolioRepository.nextID())
        DomainRegistry.portfolioRepository.save(result)
        return result
    }

    public func prepareForRecovery() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        wallet.reset()
        wallet.prepareForRecovery()
        DomainRegistry.walletRepository.save(wallet)
    }

    // MARK: - Getting Ready for Recovery

    public func change(address: Address) {
        do {
            try validate(address: address)
            changeWallet(address: address)
            try pullWalletData()
        } catch let error {
            DomainRegistry.errorStream.post(serviceError(from: error))
        }
    }

    private func validate(address: Address) throws {
        let contract = WalletProxyContractProxy(address)
        let masterCopyAddress = try contract.masterCopyAddress()
        try assertNotNil(masterCopyAddress, RecoveryServiceError.invalidContractAddress)
        try assertTrue(config.validMasterCopyAddresses.contains(masterCopyAddress!),
                       RecoveryServiceError.invalidContractAddress)
    }

    private func changeWallet(address: Address) {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        wallet.changeAddress(address)
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(WalletAddressChanged())
    }

    private func pullWalletData() throws {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let contract = SafeOwnerManagerContractProxy(wallet.address!)
        let existingOwnerAddresses = try contract.getOwners()
        let confirmationCount = try contract.getThreshold()
        for address in existingOwnerAddresses {
            wallet.addOwner(Owner(address: address, role: .unknown))
        }
        wallet.changeConfirmationCount(confirmationCount)
        DomainRegistry.walletRepository.save(wallet)
    }

    public func provide(recoveryPhrase: String) {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let accountOrNil = DomainRegistry.encryptionService.deriveExternallyOwnedAccount(from: recoveryPhrase)
        guard let recoveryAccount = accountOrNil else {
            DomainRegistry.errorStream.post(RecoveryServiceError.recoveryPhraseInvalid)
            return
        }
        let derivedAccount = DomainRegistry.encryptionService.deriveExternallyOwnedAccount(from: recoveryAccount, at: 1)
        let hasRecoveryAccounts = wallet.contains(owner: owner(from: recoveryAccount)) &&
            wallet.contains(owner: owner(from: derivedAccount))
        guard hasRecoveryAccounts else {
            DomainRegistry.errorStream.post(RecoveryServiceError.recoveryAccountsNotFound)
            return
        }
        save(recoveryAccount)
        save(derivedAccount)
        wallet.addOwner(Owner(address: recoveryAccount.address, role: .paperWallet))
        wallet.addOwner(Owner(address: derivedAccount.address, role: .paperWalletDerived))
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(WalletRecoveryAccountsAccepted())
    }

    private func owner(from account: ExternallyOwnedAccount) -> Owner {
        return Owner(address: Address(account.address.value.lowercased()), role: .unknown)
    }

    private func save(_ account: ExternallyOwnedAccount) {
        if DomainRegistry.externallyOwnedAccountRepository.find(by: account.address) == nil {
            DomainRegistry.externallyOwnedAccountRepository.save(account)
        }
    }

    // MARK: - Recovery Transaction

    public func createRecoveryTransaction() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        if let tx = DomainRegistry.transactionRepository.findBy(type: .walletRecovery, wallet: wallet.id) {
            DomainRegistry.transactionRepository.remove(tx)
        }
        RecoveryTransactionBuilder(multiSendContractAddress: config.multiSendContractAddress).main()
    }

    public func isRecoveryTransactionReadyToSubmit() -> Bool {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        guard let tx = DomainRegistry.transactionRepository.findBy(type: .walletRecovery, wallet: wallet.id) else {
            return false
        }
        guard let balance = DomainRegistry.accountRepository.find(id: tx.accountID)?.balance else {
            return false
        }
        guard let estimate = tx.feeEstimate else { return false }
        let requiredBalance = estimate.total
        return balance >= requiredBalance.amount
    }

    public func resume() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let tx = DomainRegistry.transactionRepository.findBy(type: .walletRecovery, wallet: wallet.id)!

        if !wallet.isReadyToUse && !wallet.isRecoveryInProgress && tx.status == .signing {
            submitRecoveryTransaction()
        } else if wallet.isFinalizingRecovery && tx.status == .success {
            postProcessing()
        } else if wallet.isRecoveryInProgress && tx.status == .pending {
            subscribeForTransactionProcessing()
        } else if wallet.isRecoveryInProgress && (tx.status == .success || tx.status == .failed) {
            handleTransactionProgress(tx, wallet)
        } else {
            preconditionFailure("Invalid wallet and transaction state")
        }
    }

    private func submitRecoveryTransaction() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let tx = DomainRegistry.transactionRepository.findBy(type: .walletRecovery, wallet: wallet.id)!

        let txHash: TransactionHash

        let signatures = tx.signatures.sorted { $0.address.value.lowercased() < $1.address.value.lowercased() }.map {
            DomainRegistry.encryptionService.ethSignature(from: $0)
        }
        do {
            let request = SubmitTransactionRequest(transaction: tx, signatures: signatures)
            let response = try DomainRegistry.transactionRelayService.submitTransaction(request: request)
            txHash = TransactionHash(response.transactionHash)
        } catch let error {
            DomainRegistry.errorStream.post(serviceError(from: error))
            return
        }

        tx.set(hash: txHash)
        tx.proceed()
        DomainRegistry.transactionRepository.save(tx)

        wallet.proceed()
        DomainRegistry.walletRepository.save(wallet)

        assert(tx.status == .pending, "Invalid after-submission recovery state")
        assert(wallet.isRecoveryInProgress && !wallet.isFinalizingRecovery, "Invalid after-submission wallet state")

        subscribeForTransactionProcessing()
    }

    private func subscribeForTransactionProcessing() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let tx = DomainRegistry.transactionRepository.findBy(type: .walletRecovery, wallet: wallet.id)!

        assert(wallet.isRecoveryInProgress && !wallet.isFinalizingRecovery && tx.status == .pending,
               "Invalid pending recovery state")

        guard tx.status == .pending else { return }
        DomainRegistry.eventPublisher.subscribe(self) { [weak self] (_: TransactionStatusUpdated) in
            guard let `self` = self else { return }
            guard let tx = DomainRegistry.transactionRepository.findBy(type: .walletRecovery, wallet: wallet.id) else {
                DomainRegistry.eventPublisher.unsubscribe(self)
                return
            }
            if tx.status == .pending { return }
            DomainRegistry.eventPublisher.unsubscribe(self)
            self.handleTransactionProgress(tx, wallet)
        }
    }

    private func handleTransactionProgress(_ tx: Transaction, _ wallet: Wallet) {
        assert(wallet.isRecoveryInProgress && !wallet.isFinalizingRecovery &&
            (tx.status == .success || tx.status == .failed), "Invalid tx updated state")
        if tx.status == .success {
            wallet.proceed()
            self.postProcessing()
        } else if tx.status == .failed {
            wallet.proceed()
            wallet.cancel()
            self.cancelRecovery()
        }
    }

    private func postProcessing() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let tx = DomainRegistry.transactionRepository.findBy(type: .walletRecovery, wallet: wallet.id)!

        assert(wallet.isFinalizingRecovery && tx.status == .success, "Invalid post-processing state")

        do {
            let ownersContract = SafeOwnerManagerContractProxy(wallet.address!)

            let remoteOwners = try ownersContract.getOwners()
                .map { $0.value.lowercased() }.sorted()
            let localOwners = wallet.owners.filter { $0.role != .unknown }
                .map { $0.address.value.lowercased() }.sorted()
            try assertEqual(localOwners, remoteOwners, RecoveryServiceError.failedToChangeOwners)

            let remoteThreshold = try ownersContract.getThreshold()
            let localThreshold = wallet.confirmationCount
            try assertEqual(localThreshold, remoteThreshold, RecoveryServiceError.failedToChangeConfirmationCount)

            DomainRegistry.externallyOwnedAccountRepository.remove(address: wallet.owner(role: .paperWallet)!.address)
            DomainRegistry.externallyOwnedAccountRepository.remove(address:
                wallet.owner(role: .paperWalletDerived)!.address)

            wallet.proceed()
            wallet.removeOwner(role: .unknown)
            DomainRegistry.walletRepository.save(wallet)

            try? notifyDidCreate(wallet)
        } catch let error {
            wallet.cancel()
            cancelRecovery()
            DomainRegistry.errorStream.post(error)
        }
    }

    private func notifyDidCreate(_ wallet: Wallet) throws {
        try DomainRegistry.communicationService.notifyWalletCreated(walletID: wallet.id)
    }

    public func isRecoveryInProgress() -> Bool {
        return DomainRegistry.walletRepository.selectedWallet()?.isRecoveryInProgress == true
    }

    public func cancelRecovery() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        if let tx = DomainRegistry.transactionRepository.findBy(type: .walletRecovery, wallet: wallet.id) {
            DomainRegistry.transactionRepository.remove(tx)
        }
        wallet.reset()
        wallet.prepareForRecovery()
        DomainRegistry.walletRepository.save(wallet)
    }

}

public class WalletAddressChanged: DomainEvent {}

public class WalletRecoveryAccountsAccepted: DomainEvent {}

public class WalletBecameReadyForRecovery: DomainEvent {}

fileprivate extension Address {

    var normalized: Address {
        return Address(value.lowercased())
    }
}

public struct OwnerLinkedList {

    var list = [SafeOwnerManagerContractProxy.sentinelAddress]

    public init() {}

    public mutating func add(_ owner: Owner) {
        add(owner.address)
    }

    public mutating func add(_ owner: Address) {
        let sentinel = list.removeLast()
        if list.isEmpty {
            list.append(sentinel)
        }
        list.append(owner.normalized)
        list.append(sentinel)
    }

    public mutating func replace(_ oldOwner: Owner, with newOwner: Owner) {
        replace(oldOwner.address, with: newOwner.address)
    }

    public mutating func replace(_ oldOwner: Address, with newOwner: Address) {
        guard let index = list.firstIndex(of: oldOwner.normalized) else { return }
        list[index] = newOwner.normalized
    }

    public mutating func remove(_ owner: Owner) {
        remove(owner.address)
    }

    public mutating func remove(_ address: Address) {
        if let index = list.firstIndex(of: address.normalized) {
            list.remove(at: index)
        }
    }

    public func addressBefore(_ owner: Owner) -> Address {
        return addressBefore(owner.address)
    }

    public func addressBefore(_ owner: Address) -> Address {
        let index = list.firstIndex(of: owner.normalized)!
        return list[index - 1]
    }

    public func contains(_ owner: Address) -> Bool {
        return list.contains(owner.normalized)
    }

    public func contains(_ owner: Owner) -> Bool {
        return contains(owner.address)
    }

}

public struct WalletScheme: Equatable, CustomStringConvertible {

    public var confirmations: Int
    public var owners: Int

    public init(confirmations: Int, owners: Int) {
        self.confirmations = confirmations
        self.owners = owners
    }

    public static let withoutExtension = WalletScheme(confirmations: 1, owners: 3)
    public static let withExtension = WalletScheme(confirmations: 2, owners: 4)

    public var description: String {
        return "(\(confirmations)/\(owners))"
    }
}

fileprivate func serviceError(from error: Error) -> Error {
    guard case let JSONHTTPClient.Error.networkRequestFailed(_, response, _) = error else { return error }
    guard let httpResponse = response as? HTTPURLResponse else { return error }
    switch httpResponse.statusCode {
    case 400: return RecoveryServiceError.failedToCreateValidTransactionData
    case 404: return RecoveryServiceError.walletNotFound
    case 422: return RecoveryServiceError.failedToCreateValidTransaction
    case 500: return RecoveryServiceError.internalServerError
    default: return error
    }
}


class RecoveryTransactionBuilder {

    let isDebugging = false

    var wallet: Wallet!
    var accountID: AccountID!
    var oldScheme: WalletScheme!
    var newScheme: WalletScheme!
    var readonlyOwnerAddresses: [String]!

    var ownerList: OwnerLinkedList!
    var modifiableOwners: [Owner]!

    var multiSendContractAddress: Address!

    var ownerContractProxy: SafeOwnerManagerContractProxy!
    var multiSendContractProxy: MultiSendContractProxy!

    var supportedModifiableOwnerCounts = [1, 2]
    var supportedSchemes: [WalletScheme] = [.withoutExtension, .withExtension]

    var transaction: Transaction!

    init(multiSendContractAddress: Address) {
        self.multiSendContractAddress = multiSendContractAddress
        wallet = DomainRegistry.walletRepository.selectedWallet()!
        accountID = AccountID(tokenID: Token.Ether.id, walletID: wallet.id)

        ownerContractProxy = SafeOwnerManagerContractProxy(wallet.address!)
        multiSendContractProxy = MultiSendContractProxy(multiSendContractAddress)

        print("Wallet \(wallet.id), address \(wallet.address!)")

        transaction = newTransaction()
            .change(sender: wallet.address!)
            .change(amount: .ether(0))
    }

    func main() {
        pullData()
        guard isSupportedSafeOwners() && isSupportedScheme() else { return }
        buildData()
        guard let estimation = self.estimate() else { return }
        calculateFees(basedOn: estimation)
        seal()
        sign()
        save()
        notify()
    }

    func pullData() {
        do {
            wallet.removeOwner(role: .unknown)
            let remoteOwners = try ownerContractProxy.getOwners()
            remoteOwners.forEach { wallet.addOwner(Owner(address: $0, role: .unknown)) }

            let remoteThreshold = try ownerContractProxy.getThreshold()
            wallet.changeConfirmationCount(remoteThreshold)

            oldScheme = oldWalletScheme()
            newScheme = newWalletScheme()
            print("Old scheme: ", oldScheme)
            print("New scheme: ", newScheme)

            ownerList = ownerLinkedList()

            readonlyOwnerAddresses = readonlyAddresses()
            print("Readonly owners: ", readonlyOwnerAddresses)

            modifiableOwners = mutableOwners()
            print("Modifiable owners: ", modifiableOwners)

            try DomainRegistry.accountUpdateService.updateAccountsBalances()
        } catch let error {
            DomainRegistry.errorStream.post(error)
        }
    }

    private func print(_ items: Any...) {
        #if DEBUG
        guard isDebugging else { return }
        Swift.print(items)
        #endif
    }

    fileprivate func newTransaction() -> Transaction {
        return Transaction(id: DomainRegistry.transactionRepository.nextID(),
                           type: .walletRecovery,
                           walletID: wallet.id,
                           accountID: accountID)
    }

    fileprivate func oldWalletScheme() -> WalletScheme {
        return WalletScheme(confirmations: wallet.confirmationCount,
                            owners: wallet.owners.filter { $0.role == .unknown }.count)
    }

    fileprivate func newWalletScheme() -> WalletScheme {
        return WalletScheme(confirmations: wallet.owner(role: .browserExtension) == nil ? 1 : 2,
                            owners: wallet.owners.filter { $0.role != .unknown }.count)
    }

    private func ownerLinkedList() -> OwnerLinkedList {
        var ownerList = OwnerLinkedList()
        wallet.owners.filter { $0.role == .unknown }.forEach { ownerList.add($0) }
        return ownerList
    }

    private func readonlyAddresses() -> [String] {
        return wallet.owners
            .filter { $0.role == .paperWallet || $0.role == .paperWalletDerived }
            .map { $0.address.value.lowercased() }
    }

    private func mutableOwners() -> [Owner] {
        let readonly = readonlyAddresses()
        return wallet.owners.filter {
            $0.role == .unknown && !readonly.contains($0.address.value.lowercased())
        }
    }

    fileprivate func sign() {
        let paperWalletEOA = DomainRegistry.externallyOwnedAccountRepository.find(by:
            wallet.owner(role: .paperWallet)!.address)!
        let firstSignature = DomainRegistry.encryptionService.sign(transaction: transaction,
                                                                   privateKey: paperWalletEOA.privateKey)
        transaction.add(signature: Signature(data: firstSignature, address: paperWalletEOA.address))
        if oldScheme.confirmations == 2 {
            let derivedEOA = DomainRegistry.externallyOwnedAccountRepository.find(by:
                wallet.owner(role: .paperWalletDerived)!.address)!
            let secondSignature = DomainRegistry.encryptionService.sign(transaction: transaction,
                                                                        privateKey: derivedEOA.privateKey)
            transaction.add(signature: Signature(data: secondSignature, address: derivedEOA.address))
        }
    }

    fileprivate func calculateFees(basedOn estimationResponse: EstimateTransactionRequest.Response) {
        let gasPrice = TokenAmount(amount: TokenInt(estimationResponse.gasPrice), token: Token.Ether)
        let estimate = TransactionFeeEstimate(gas: estimationResponse.safeTxGas,
                                              dataGas: estimationResponse.dataGas,
                                              operationalGas: estimationResponse.operationalGas,
                                              gasPrice: gasPrice)
        let fee = TokenInt(estimate.gas + estimate.dataGas) * estimate.gasPrice.amount
        let feeAmount = TokenAmount(amount: fee, token: gasPrice.token)
        transaction.change(fee: feeAmount)
            .change(feeEstimate: estimate)
            .change(nonce: String(estimationResponse.nextNonce))
    }

    fileprivate func seal() {
        transaction.change(hash: DomainRegistry.encryptionService.hash(of: transaction))
        transaction.proceed()
    }

    fileprivate func buildData() {
        switch (oldScheme!, newScheme!) {
        case (.withoutExtension, .withoutExtension):
            buildNoExtensionToNoExtensionData()
        case (.withoutExtension, .withExtension):
            buildNoExtensionToExtensionData()
        case (.withExtension, .withoutExtension):
            buildExtensionToNoExtensionData()
        case (.withExtension, .withExtension):
            buildExtensionToExtensionData()
        default:
            preconditionFailure("Unreachable")
        }
    }

    fileprivate func buildNoExtensionToNoExtensionData() {
        buildTransactionData([swapOwnerData(role: .thisDevice)])
    }

    fileprivate func buildNoExtensionToExtensionData() {
        buildTransactionData([swapOwnerData(role: .thisDevice), addOwnerData(role: .browserExtension)])
    }

    private func buildExtensionToExtensionData() {
        buildTransactionData([swapOwnerData(role: .thisDevice), swapOwnerData(role: .browserExtension)])
    }

    private func buildExtensionToNoExtensionData() {
        buildTransactionData([swapOwnerData(role: .thisDevice), removeOwnerData()])
    }

    private func buildTransactionData(_ data: [Data]) {
        let input = data.filter { !$0.isEmpty }
        switch input.count {
        case 0: // may happen when the database was not updated but previous recovery tx went through
            transaction.change(recipient: wallet.address!)
                .change(operation: .call)
                .change(data: nil)
        case 1:
            transaction.change(recipient: wallet.address!)
                .change(operation: .call)
                .change(data: input.first)
        default:
            let address = DomainRegistry.encryptionService.address(from: multiSendContractProxy.contract.value)!
            transaction.change(recipient: address)
                .change(data: multiSendData(input))
                .change(operation: .delegateCall)
        }
    }

    private func swapOwnerData(role: OwnerRole) -> Data {
        let ownerToReplace = modifiableOwners.removeFirst()
        let addressBeforeReplaceableOwner = ownerList.addressBefore(ownerToReplace)
        let newOwner = wallet.owner(role: role)!
        guard newOwner.address.normalized != ownerToReplace.address.normalized else {
            return Data()
        }
        let data = ownerContractProxy.swapOwner(prevOwner: addressBeforeReplaceableOwner,
                                                old: ownerToReplace.address,
                                                new: newOwner.address)
        ownerList.replace(ownerToReplace, with: newOwner)
        return data
    }

    private func addOwnerData(role: OwnerRole) -> Data {
        let newOwner = wallet.owner(role: role)!
        guard !ownerList.contains(newOwner) else {
            return Data()
        }
        let data = ownerContractProxy.addOwner(newOwner.address, newThreshold: newScheme.confirmations)
        ownerList.add(newOwner)
        wallet.changeConfirmationCount(newScheme.confirmations)
        return data
    }

    private func removeOwnerData() -> Data {
        let ownerToRemove = modifiableOwners.removeFirst()
        let addressBeforeRemovedOwner = ownerList.addressBefore(ownerToRemove)
        let data = ownerContractProxy.removeOwner(prevOwner: addressBeforeRemovedOwner,
                                                  owner: ownerToRemove.address,
                                                  newThreshold: newScheme.confirmations)
        ownerList.remove(ownerToRemove)
        wallet.changeConfirmationCount(newScheme.confirmations)
        return data
    }

    private func multiSendData(_ transactionData: [Data]) -> Data {
        return multiSendContractProxy.multiSend(transactionData.filter { !$0.isEmpty }.map {
            (operation: .call, to: wallet.address!, value: 0, data: $0) })
    }

    private func isSupportedSafeOwners() -> Bool {
        guard supportedModifiableOwnerCounts.contains(modifiableOwners.count) else {
            let message = "Expected one of \(supportedModifiableOwnerCounts) mutable owners" +
            ", but found \(modifiableOwners.count)"
            DomainRegistry.errorStream.post(RecoveryServiceError.unsupportedWalletConfiguration(message))
            return false
        }
        return true
    }

    private func isSupportedScheme() -> Bool {
        guard supportedSchemes.contains(oldScheme) && supportedSchemes.contains(newScheme) else {
            let message = "Expected \(supportedSchemes) confirmations/owners, but got \(oldScheme!)"
            DomainRegistry.errorStream.post(RecoveryServiceError.unsupportedWalletConfiguration(message))
            return false
        }
        return true
    }

    private func estimate() -> EstimateTransactionRequest.Response? {
        let formattedRecipient = DomainRegistry.encryptionService.address(from: transaction.ethTo.value)!
        let estimationRequest = EstimateTransactionRequest(safe: transaction.sender!,
                                                           to: formattedRecipient,
                                                           value: String(transaction.ethValue),
                                                           data: transaction.ethData,
                                                           operation: transaction.operation!)
        do {
            return try DomainRegistry.transactionRelayService.estimateTransaction(request: estimationRequest)
        } catch let error {
            DomainRegistry.errorStream.post(serviceError(from: error))
            return nil
        }
    }

    private func save() {
        DomainRegistry.transactionRepository.save(transaction)
        DomainRegistry.walletRepository.save(wallet)
    }

    private func notify() {
        DomainRegistry.eventPublisher.publish(WalletBecameReadyForRecovery())
    }

}
