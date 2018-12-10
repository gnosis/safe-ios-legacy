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
    case notEnoughFunds
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
            DomainRegistry.errorStream.post(error)
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
        let accountID = AccountID(tokenID: Token.Ether.id, walletID: wallet.id)
        guard let balance = DomainRegistry.accountRepository.find(id: accountID)?.balance else {
            return false
        }
        guard let estimate = tx.feeEstimate else { return false }
        let requiredBalance = estimate.total
        return balance >= requiredBalance.amount
    }

    public func submitRecoveryTransaction() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let tx = DomainRegistry.transactionRepository.findBy(type: .walletRecovery, wallet: wallet.id)!

        let txHash: TransactionHash

        let signatures = tx.signatures.sorted { $0.address.value < $1.address.value }.map {
            DomainRegistry.encryptionService.ethSignature(from: $0)
        }
        do {
            let request = SubmitTransactionRequest(transaction: tx, signatures: signatures)
            let response = try DomainRegistry.transactionRelayService.submitTransaction(request: request)
            txHash = TransactionHash(response.transactionHash)
        } catch let error {
            DomainRegistry.errorStream.post(error)
            return
        }

        tx.set(hash: txHash)
        tx.proceed()
        DomainRegistry.transactionRepository.save(tx)
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

}

public struct WalletScheme: Equatable, CustomStringConvertible {

    public var confirmations: Int
    public var owners: Int

    public init(confirmations: Int, owners: Int) {
        self.confirmations = confirmations
        self.owners = owners
    }

    public static let withoutExtension = WalletScheme(confirmations: 1, owners: 3)
    public static let hasExtension = WalletScheme(confirmations: 2, owners: 4)

    public var description: String {
        return "(\(confirmations)/\(owners))"
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
    var supportedSchemes: [WalletScheme] = [.withoutExtension, .hasExtension]

    var transaction: Transaction!

    init(multiSendContractAddress: Address) {
        self.multiSendContractAddress = multiSendContractAddress

        wallet = DomainRegistry.walletRepository.selectedWallet()!
        print("Wallet \(wallet.id), address \(wallet.address!)")
        accountID = AccountID(tokenID: Token.Ether.id, walletID: wallet.id)

        oldScheme = oldWalletScheme()
        newScheme = newWalletScheme()
        print("Old scheme: ", oldScheme)
        print("New scheme: ", newScheme)

        ownerList = ownerLinkedList()

        readonlyOwnerAddresses = readonlyAddresses()
        print("Readonly owners: ", readonlyOwnerAddresses)

        modifiableOwners = mutableOwners()
        print("Modifiable owners: ", modifiableOwners)

        ownerContractProxy = SafeOwnerManagerContractProxy(wallet.address!)
        multiSendContractProxy = MultiSendContractProxy(multiSendContractAddress)

        transaction = newTransaction()
            .change(sender: wallet.address!)
            .change(amount: .ether(0))
    }

    func main() {
        guard isSupportedSafeOwners() && isSupportedScheme() else { return }
        buildData()
        guard let estimation = self.estimate() else { return }
        calculateFees(basedOn: estimation)
        seal()
        sign()
        save()
        notify()
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

    fileprivate func swapDeviceOwner() {
        print("Recovery \(oldScheme!)-> \(newScheme!)")

        let deviceSwapOwner = modifiableOwners.removeFirst()
        let addressBeforeSwapOwner = ownerList.addressBefore(deviceSwapOwner)
        let deviceOwner = wallet.owner(role: .thisDevice)!
        let data = ownerContractProxy.swapOwner(prevOwner: addressBeforeSwapOwner,
                                                old: deviceSwapOwner.address,
                                                new: deviceOwner.address)

        print("Owners: ", ownerList.list)
        print("Swap \(deviceSwapOwner) -> \(deviceOwner)")

        transaction.change(data: data)
            .change(recipient: wallet.address!)
            .change(operation: .call)
    }

    // FIXME: if swapping to the same owner - then what? need to fake recovery

    fileprivate func swapDeviceOwnerAndAddExtensionOwner() {
        print("Recovery \(oldScheme!)-> \(newScheme!)")

        let deviceSwapOwner = modifiableOwners.removeFirst()
        let addressBeforeSwapOwner = ownerList.addressBefore(deviceSwapOwner)
        let deviceOwner = wallet.owner(role: .thisDevice)!
        let swapOwnerData = ownerContractProxy.swapOwner(prevOwner: addressBeforeSwapOwner,
                                                         old: deviceSwapOwner.address,
                                                         new: deviceOwner.address)

        print("Owners: ", ownerList.list)
        print("Swap \(deviceSwapOwner) -> \(deviceOwner)")

        ownerList.replace(deviceSwapOwner, with: deviceOwner)

        let extensionOwner = wallet.owner(role: .browserExtension)!

        print("Owners: ", ownerList.list)
        print("Add \(extensionOwner)")

        ownerList.add(extensionOwner)
        print("Owners: ", ownerList.list)

        let addOwnerData = ownerContractProxy.addOwner(extensionOwner.address, newThreshold: 2)
        wallet.changeConfirmationCount(2)

        print("Threshold changed to \(wallet.confirmationCount)")

        let data = multiSendContractProxy.multiSend([
            (operation: .call, to: wallet.address!, value: 0, data: swapOwnerData),
            (operation: .call, to: wallet.address!, value: 0, data: addOwnerData)])

        let address = DomainRegistry.encryptionService.address(from: multiSendContractProxy.contract.value)!
        transaction.change(recipient: address)
            .change(data: data)
            .change(operation: .delegateCall)
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
            swapDeviceOwner()
        case (.withoutExtension, .hasExtension):
            swapDeviceOwnerAndAddExtensionOwner()
        default:
            preconditionFailure("Unreachable")
        }
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
            DomainRegistry.errorStream.post(error)
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
