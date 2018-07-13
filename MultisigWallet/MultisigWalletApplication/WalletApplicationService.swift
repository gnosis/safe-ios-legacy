//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common
import BigInt

public class WalletApplicationService: Assertable {

    private var ethereumService: EthereumApplicationService {
        return ApplicationServiceRegistry.ethereumService
    }

    private var notificationService: NotificationDomainService {
        return DomainRegistry.notificationService
    }

    private var tokensService: TokensDomainService {
        return DomainRegistry.tokensService
    }

    public enum WalletState {
        case none
        case newDraft
        case readyToDeploy
        case deploymentStarted
        // TODO: remove addressKnown state
        case addressKnown
        case accountFunded
        case notEnoughFunds
        case deploymentAcceptedByBlockchain
        // TODO: remove deploymentSuccess state
        case deploymentSuccess
        case deploymentFailed
        case readyToUse

        var isBeingCreated: Bool {
            return self == .newDraft || self == .readyToDeploy || isPendingDeployment
        }

        var isPendingDeployment: Bool {
            return WalletState.pendingCreationStates.contains(self)
        }

        var isValidForAccountUpdate: Bool {
            return WalletState.validAccountUpdateStates.contains(self)
        }

        var isReadyToUse: Bool {
            return self == .readyToUse
        }

        private static let pendingCreationStates: [WalletState] = [
            .deploymentStarted,
            .addressKnown,
            .accountFunded,
            .notEnoughFunds,
            .deploymentAcceptedByBlockchain,
            .deploymentSuccess
        ]

        private static let validAccountUpdateStates: [WalletState] = [
            .deploymentStarted,
            .addressKnown,
            .notEnoughFunds
        ]
    }

    public enum OwnerType {
        case thisDevice
        case browserExtension
        case paperWallet

        static let all: [OwnerType] = [.thisDevice, .browserExtension, .paperWallet]

        var kind: String {
            switch self {
            case .thisDevice: return "device"
            case .browserExtension: return "extesnion"
            case .paperWallet: return "paperWallet"
            }
        }
    }

    public enum Error: String, LocalizedError, Hashable {
        case oneOrMoreOwnersAreMissing
        case selectedWalletNotFound
        case invalidWalletState
        case accountNotFound
        case missingWalletAddress
        case creationTransactionHashNotFound
        case networkError
        case validationFailed
        case exceededExpirationDate
        case unknownError
    }

    public static let requiredConfirmationCount: Int = 2

    public var selectedWalletState: WalletState {
        guard let wallet = findSelectedWallet() else { return .none }
        switch wallet.status {
        case .newDraft:
            return .newDraft
        case .readyToDeploy:
            return .readyToDeploy
        case .deploymentStarted:
            return .deploymentStarted
        case .addressKnown:
            let account = findAccount("ETH")!
            if account.balance == 0 {
                return .addressKnown
            } else if account.balance < account.minimumDeploymentTransactionAmount {
                return .notEnoughFunds
            } else {
                return .accountFunded
            }
        case .deploymentAcceptedByBlockchain:
            return .deploymentAcceptedByBlockchain
        case .deploymentSuccess:
            return .deploymentSuccess
        case .deploymentFailed:
            return .deploymentFailed
        case .readyToUse:
            return .readyToUse
        }
    }

    public var hasReadyToUseWallet: Bool {
        return selectedWalletState.isReadyToUse
    }

    public var hasPendingWalletCreation: Bool {
        return selectedWalletState.isPendingDeployment
    }

    public var isSafeCreationInProgress: Bool {
        return selectedWalletState.isBeingCreated
    }

    public var canChangeAccount: Bool {
        return selectedWalletState.isValidForAccountUpdate
    }

    public var selectedWalletAddress: String? {
        return findSelectedWallet()?.address?.value
    }

    public var minimumDeploymentAmount: Int? {
        return findAccount("ETH")?.minimumDeploymentTransactionAmount
    }

    private var statusUpdateHandlers = [String: () -> Void]()

    public init() {}

    // MARK: - Wallet

    public func createNewDraftWallet() {
        notifyWalletStateChangesAfter {
            let portfolio = fetchOrCreatePortfolio()
            let address = ethereumService.generateExternallyOwnedAccount().address
            let owner = Wallet.createOwner(address: address)
            let wallet = Wallet(id: DomainRegistry.walletRepository.nextID(),
                                owner: owner,
                                kind: OwnerType.thisDevice.kind)
            let account = Account(id: AccountID(token: "ETH"), walletID: wallet.id, balance: 0, minimumAmount: 0)
            portfolio.addWallet(wallet.id)
            DomainRegistry.walletRepository.save(wallet)
            DomainRegistry.portfolioRepository.save(portfolio)
            DomainRegistry.accountRepository.save(account)
        }
    }

    private func fetchOrCreatePortfolio() -> Portfolio {
        if let result = DomainRegistry.portfolioRepository.portfolio() {
            return result
        } else {
            return Portfolio(id: DomainRegistry.portfolioRepository.nextID())
        }
    }

    public func startDeployment() throws {
        do {
            if selectedWalletState == .readyToDeploy {
                doStartDeployment()
            }
            if selectedWalletState == .deploymentStarted {
                let data = try requestWalletCreation()
                assignBlockchainAddress(data.safe)
                updateMinimumFunding(account: "ETH", amount: data.payment)
            }
            if selectedWalletState == .notEnoughFunds || selectedWalletState == .addressKnown {
                try startObservingWalletBalance()
            } else if selectedWalletState == .accountFunded {
                try createWalletInBlockchain()
            } else if selectedWalletState == .deploymentAcceptedByBlockchain {
                try waitForPendingTransaction()
            } else {
                throw Error.invalidWalletState
            }
        } catch let error {
            abortDeployment()
            throw error
        }
    }

    private func requestWalletCreation() throws -> SafeCreationTransactionData {
        let owners: [String] = OwnerType.all.compactMap { ownerAddress(of: $0) }
        try assertEqual(owners.count, OwnerType.all.count, Error.oneOrMoreOwnersAreMissing)
        let confirmationCount = WalletApplicationService.requiredConfirmationCount
        return try ethereumService.createSafeCreationTransaction(owners: owners, confirmationCount: confirmationCount)
    }

    private func doStartDeployment() {
        mutateSelectedWallet { wallet in
            wallet.startDeployment()
        }
    }

    private func assignBlockchainAddress(_ address: String) {
        mutateSelectedWallet { wallet in
            wallet.changeBlockchainAddress(BlockchainAddress(value: address))
        }
    }

    private func startObservingWalletBalance() throws {
        let address = findSelectedWallet()!.address!
        try ethereumService.observeChangesInBalance(address: address.value, every: 2) { [weak self] newBalance in
            guard let `self` = self else { return RepeatingShouldStop.yes }
            return self.didUpdateBalance(account: address.value, newBalance: newBalance)
        }
    }

    private func didUpdateBalance(account: String, newBalance: BigInt) -> Bool {
        do {
            guard [WalletState.addressKnown, WalletState.notEnoughFunds, WalletState.accountFunded]
                .contains(selectedWalletState) else {
                return RepeatingShouldStop.yes
            }
            // TODO: BigInt support
            update(account: "ETH", newBalance: Int(newBalance)) // mutates selectedWalletState
            if selectedWalletState == .accountFunded {
                try createWalletInBlockchain()
                return RepeatingShouldStop.yes
            }
            return RepeatingShouldStop.no
        } catch let error {
            ApplicationServiceRegistry.logger.fatal("Failed to update ETH account balance", error: error)
            try? markDeploymentFailed()
            return RepeatingShouldStop.yes
        }
    }

    private func createWalletInBlockchain() throws {
        let address = findSelectedWallet()!.address!.value
        // TODO: if the call fails, show error in UI and possibility to retry with a button
        try ethereumService.startSafeCreation(address: address)
        guard selectedWalletState == .accountFunded else { return }
        markDeploymentAcceptedByBlockchain()
        try waitForPendingTransaction()
    }

    private func waitForPendingTransaction() throws {
        let wallet = findSelectedWallet()!
        var hash = wallet.creationTransactionHash
        if hash == nil {
            let address = wallet.address!.value
            hash = try ethereumService.waitForCreationTransaction(address: address)
            try storeTransactionHash(hash: hash!)
        }
        let isSuccess = try ethereumService.waitForPendingTransaction(hash: hash!)
        guard selectedWalletState == .deploymentAcceptedByBlockchain else { return }
        didFinishDeployment(success: isSuccess)
    }

    private func storeTransactionHash(hash: String) throws {
        mutateSelectedWallet { wallet in
            wallet.assignCreationTransaction(hash: hash)
        }
    }

    private func didFinishDeployment(success: Bool) {
        if success {
            removePaperWallet()
            try? notifySafeCreated() // TODO: handle the case
            markDeploymentSuccess()
            finishDeployment()
        } else {
            ApplicationServiceRegistry.logger.fatal("Blockchain transaction failed")
            try? markDeploymentFailed()
        }
    }

    private func notifySafeCreated() throws {
        let sender = ownerAddress(of: .thisDevice)!
        let recipient = ownerAddress(of: .browserExtension)!
        let message = notificationService.safeCreatedMessage(at: selectedWalletAddress!)
        let senderSignature = ethereumService.sign(message: "GNO" + message, by: sender)!
        let request = SendNotificationRequest(message: message, to: recipient, from: senderSignature)
        try notificationService.send(notificationRequest: request)
    }

    private func fetchBalance() throws {
        let address = findSelectedWallet()!.address!.value
        let newBalance = try ethereumService.balance(address: address)
        // TODO: BigInt support
        update(account: "ETH", newBalance: Int(newBalance))
    }

    private func removePaperWallet() {
        let paperWallet = ownerAddress(of: .paperWallet)!
        ethereumService.removeExternallyOwnedAccount(address: paperWallet)
    }

    private func markReadyToDeploy() {
        mutateSelectedWallet { wallet in
            wallet.markReadyToDeploy()
        }
    }

    public func markDeploymentAcceptedByBlockchain() {
        mutateSelectedWallet { wallet in
            wallet.markDeploymentAcceptedByBlockchain()
        }
    }

    public func markDeploymentFailed() throws {
        mutateSelectedWallet { wallet in
            wallet.markDeploymentFailed()
        }
    }

    public func markDeploymentSuccess() {
        mutateSelectedWallet { wallet in
            wallet.markDeploymentSuccess()
        }
    }

    public func abortDeployment() {
        mutateSelectedWallet { wallet in
            wallet.abortDeployment()
        }
    }

    public func finishDeployment() {
        mutateSelectedWallet { wallet in
            wallet.finishDeployment()
        }
    }

    private func mutateSelectedWallet(_ closure: (Wallet) -> Void) {
        notifyWalletStateChangesAfter {
            let wallet = findSelectedWallet()!
            closure(wallet)
            DomainRegistry.walletRepository.save(wallet)
        }
    }

    private func findSelectedWallet() -> Wallet? {
        guard let portfolio = DomainRegistry.portfolioRepository.portfolio(),
            let walletID = portfolio.selectedWallet,
            let wallet = DomainRegistry.walletRepository.findByID(walletID) else {
            return nil
        }
        return wallet
    }

    private func notifyWalletStateChangesAfter(_ closure: () throws -> Void) rethrows {
        let startState = selectedWalletState
        try closure()
        let endState = selectedWalletState
        if startState != endState {
            notifyStatusUpdate()
        }
    }

    // MARK: - Owners

    public func isOwnerExists(_ type: OwnerType) -> Bool {
        guard let wallet = findSelectedWallet(), wallet.owner(kind: type.kind) != nil else { return false }
        return true
    }

    public func addOwner(address: String, type: OwnerType) {
        mutateSelectedWallet { wallet in
            let owner = Wallet.createOwner(address: address)
            if wallet.owner(kind: type.kind) != nil {
                wallet.replaceOwner(with: owner, kind: type.kind)
            } else {
                wallet.addOwner(owner, kind: type.kind)
            }
            if wallet.status == .newDraft {
                let enoughOwnersExist = OwnerType.all.reduce(true) { isEnough, type in
                    isEnough && wallet.owner(kind: type.kind) != nil
                }
                if enoughOwnersExist {
                    wallet.markReadyToDeploy()
                }
            }
        }
    }

    public func addBrowserExtensionOwner(address: String, browserExtensionCode: String) throws {
        let deviceOwnerAddress = ownerAddress(of: .thisDevice)!
        let signature = ethereumService.sign(message: "GNO" + address, by: deviceOwnerAddress)!
        guard let browserExtension = browserExtension(json: browserExtensionCode) else {
            throw Error.validationFailed
        }
        do {
            let pairingRequest = PairingRequest(
                temporaryAuthorization: browserExtension,
                signature: signature,
                deviceOwnerAddress: deviceOwnerAddress)
            try notificationService.pair(pairingRequest: pairingRequest)
        } catch NotificationDomainServiceError.validationFailed {
            throw Error.validationFailed
        } catch let e as JSONHTTPClient.Error {
            switch e {
            case let .networkRequestFailed(_, _, data):
                if let data = data,
                    let dataStr = String(data: data, encoding: .utf8),
                    dataStr.range(of: "Exceeded expiration date") != nil {
                    throw Error.exceededExpirationDate
                }
                throw Error.networkError
            }
        } catch {
            throw Error.unknownError
        }
        addOwner(address: address, type: .browserExtension)
    }

    public func browserExtension(json: String) -> BrowserExtensionCode? {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter.networkDateFormatter
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        guard let jsonData = json.data(using: .utf8) else {
            return nil
        }
        do {
            var code = try decoder.decode(BrowserExtensionCode.self, from: jsonData)
            code.extensionAddress = ethereumService.address(browserExtensionCode: json)
            return code
        } catch {
            return nil
        }
    }

    public func ownerAddress(of type: OwnerType) -> String? {
        guard let wallet = findSelectedWallet(), let owner = wallet.owner(kind: type.kind) else { return nil }
        return owner.address.value
    }

    // MARK: - Accounts

    public func accountBalance(token: String) -> Int? {
       return findAccount(token)?.balance
    }

    private func updateMinimumFunding(account token: String, amount: Int) {
        assertCanChangeAccount()
        mutateAccount(token: token) { account in
            account.updateMinimumTransactionAmount(amount)
        }
    }

    private func assertCanChangeAccount() {
        try! assertTrue(selectedWalletState.isValidForAccountUpdate, Error.invalidWalletState)
    }

    public func update(account token: String, newBalance: Int) {
        assertCanChangeAccount()
        mutateAccount(token: token) { account in
            account.update(newAmount: newBalance)
        }
    }

    private func mutateAccount(token: String, closure: (Account) -> Void) {
        notifyWalletStateChangesAfter {
            let account = findAccount(token)!
            closure(account)
            DomainRegistry.accountRepository.save(account)
        }
    }

    private func findAccount(_ token: String) -> Account? {
        guard let wallet = findSelectedWallet(),
            let account = DomainRegistry.accountRepository.find(id: AccountID(token: token), walletID: wallet.id) else {
            return nil
        }
        return account
    }

    // MARK: - Wallet status update subscribing

    public func subscribe(_ update: @escaping () -> Void) -> String {
        let key = UUID().uuidString
        statusUpdateHandlers[key] = update
        return key
    }

    public func unsubscribe(subscription: String) {
        statusUpdateHandlers.removeValue(forKey: subscription)
    }

    private func notifyStatusUpdate() {
        statusUpdateHandlers.values.forEach { $0() }
    }

    // MARK: - Notifications

    public func auth() throws {
        precondition(!Thread.isMainThread)
        guard let pushToken = tokensService.pushToken() else { return }
        precondition(ownerAddress(of: .thisDevice) != nil,
                     "Owner device should have identity at the moment of calling auth()")
        let deviceOwnerAddress = ownerAddress(of: .thisDevice)!
        let signature = try blockchainService.sign(message: "GNO" + pushToken, by: deviceOwnerAddress)
        let authRequest = AuthRequest(
            pushToken: pushToken, signature: signature, deviceOwnerAddress: deviceOwnerAddress)
        do {
            try notificationService.auth(request: authRequest)
        } catch JSONHTTPClient.Error.networkRequestFailed(_, _, _) {
            throw Error.networkError
        } catch {
            throw Error.unknownError
        }
    }

}
