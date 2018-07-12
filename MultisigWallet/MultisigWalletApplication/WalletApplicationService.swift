//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common
import BigInt

public class WalletApplicationService: Assertable {

    private var blockchainService: BlockchainDomainService {
        return DomainRegistry.blockchainService
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
        do {
            let wallet = try findSelectedWallet()
            switch wallet.status {
            case .newDraft:
                return .newDraft
            case .readyToDeploy:
                return .readyToDeploy
            case .deploymentStarted:
                return .deploymentStarted
            case .addressKnown:
                let account = try findAccount("ETH")
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
        } catch Error.selectedWalletNotFound {
            return .none // all good
        } catch let e {
            ApplicationServiceRegistry.logger.error("Failed to compute selected wallet state", error: e)
        }
        return .none
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
        do {
            return try findSelectedWallet().address?.value
        } catch let error {
            ApplicationServiceRegistry.logger.error("Error getting selected wallet: \(error)")
            return nil
        }
    }

    public var minimumDeploymentAmount: Int? {
        do {
            let account = try findAccount("ETH")
            return account.minimumDeploymentTransactionAmount
        } catch {
            return nil
        }
    }

    private var statusUpdateHandlers = [String: () -> Void]()

    public init() {}

    // MARK: - Wallet

    public func createNewDraftWallet() throws {
        try notifyWalletStateChangesAfter {
            let portfolio = try fetchOrCreatePortfolio()
            let address = try blockchainService.generateExternallyOwnedAccount()
            let owner = Wallet.createOwner(address: address)
            let wallet = try Wallet(id: DomainRegistry.walletRepository.nextID(),
                                    owner: owner,
                                    kind: OwnerType.thisDevice.kind)
            let account = Account(id: AccountID(token: "ETH"), walletID: wallet.id, balance: 0, minimumAmount: 0)
            try portfolio.addWallet(wallet.id)
            try DomainRegistry.walletRepository.save(wallet)
            try DomainRegistry.portfolioRepository.save(portfolio)
            try DomainRegistry.accountRepository.save(account)
        }
    }

    private func fetchOrCreatePortfolio() throws -> Portfolio {
        if let result = try DomainRegistry.portfolioRepository.portfolio() {
            return result
        } else {
            return try Portfolio(id: DomainRegistry.portfolioRepository.nextID())
        }
    }

    public func startDeployment() throws {
        do {
            if selectedWalletState == .readyToDeploy {
                try doStartDeployment()
            }
            if selectedWalletState == .deploymentStarted {
                let data = try requestWalletCreation()
                try assignBlockchainAddress(data.walletAddress)
                try updateMinimumFunding(account: "ETH", amount: data.fee)
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
            try abortDeployment()
            throw error
        }
    }

    private func requestWalletCreation() throws -> WalletCreationData {
        let owners: [String] = OwnerType.all.compactMap { ownerAddress(of: $0) }
        try assertEqual(owners.count, OwnerType.all.count, Error.oneOrMoreOwnersAreMissing)
        let confirmationCount = WalletApplicationService.requiredConfirmationCount
        let data = try blockchainService.requestWalletCreationData(owners: owners, confirmationCount: confirmationCount)
        return data
    }

    private func doStartDeployment() throws {
        try mutateSelectedWallet { wallet in
            try wallet.startDeployment()
        }
    }

    private func assignBlockchainAddress(_ address: String) throws {
        try mutateSelectedWallet { wallet in
            try wallet.changeBlockchainAddress(BlockchainAddress(value: address))
        }
    }

    private func startObservingWalletBalance() throws {
        let wallet = try findSelectedWallet()
        guard let address = wallet.address else {
            throw Error.missingWalletAddress
        }
        try blockchainService.observeBalance(account: address.value, observer: didUpdateBalance(account:newBalance:))
    }

    private func didUpdateBalance(account: String, newBalance: BigInt) -> BlockchainBalanceObserverResponse {
        do {
            guard [WalletState.addressKnown, WalletState.notEnoughFunds, WalletState.accountFunded]
                .contains(selectedWalletState) else {
                return .stopObserving
            }
            // TODO: BigInt support
            try update(account: "ETH", newBalance: Int(newBalance)) // mutates selectedWalletState
            if selectedWalletState == .accountFunded {
                try createWalletInBlockchain()
                return .stopObserving
            }
            return .continueObserving
        } catch let error {
            ApplicationServiceRegistry.logger.fatal("Failed to update ETH account balance", error: error)
            try? markDeploymentFailed()
            return .stopObserving
        }
    }

    private func createWalletInBlockchain() throws {
        let wallet = try findSelectedWallet()
        guard let address = wallet.address else {
            throw Error.missingWalletAddress
        }
        // TODO: if the call fails, show error in UI and possibility to retry with a button
        try blockchainService.executeWalletCreationTransaction(address: address.value)
        guard selectedWalletState == .accountFunded else { return }
        try markDeploymentAcceptedByBlockchain()
        try waitForPendingTransaction()
    }

    private func waitForPendingTransaction() throws {
        let wallet = try findSelectedWallet()
        var hash = wallet.creationTransactionHash
        if hash == nil {
            guard let address = wallet.address else {
                throw Error.missingWalletAddress
            }
            hash = try blockchainService.waitForCreationTransaction(address: address.value)
            try storeTransactionHash(hash: hash!)
        }
        let isSuccess = try blockchainService.waitForPendingTransaction(hash: hash!)
        guard selectedWalletState == .deploymentAcceptedByBlockchain else { return }
        didFinishDeployment(success: isSuccess)
    }

    private func storeTransactionHash(hash: String) throws {
        try mutateSelectedWallet { wallet in
            try wallet.assignCreationTransaction(hash: hash)
        }
    }

    private func didFinishDeployment(success: Bool) {
        if success {
            do {
                try removePaperWallet()
                try? notifySafeCreated() // TODO: handle the case
                try markDeploymentSuccess()
                try finishDeployment()
            } catch let error {
                ApplicationServiceRegistry.logger.fatal("Failed to save success deployment state", error: error)
                try? markDeploymentFailed()
            }
        } else {
            ApplicationServiceRegistry.logger.fatal("Blockchain transaction failed")
            try? markDeploymentFailed()
        }
    }

    private func notifySafeCreated() throws {
        let sender = ownerAddress(of: .thisDevice)!
        let recipient = ownerAddress(of: .browserExtension)!
        let message = notificationService.safeCreatedMessage(at: selectedWalletAddress!)
        let senderSignature = try blockchainService.sign(message: "GNO" + message, by: sender)
        let request = SendNotificationRequest(message: message, to: recipient, from: senderSignature)
        try notificationService.send(notificationRequest: request)
    }

    private func fetchBalance() throws {
        let wallet = try findSelectedWallet()
        let newBalance = try blockchainService.balance(address: wallet.address!.value)
        // TODO: BigInt support
        try update(account: "ETH", newBalance: Int(newBalance))
    }

    private func removePaperWallet() throws {
        let paperWallet = ownerAddress(of: .paperWallet)!
        try blockchainService.removeExternallyOwnedAccount(address: paperWallet)
    }

    private func markReadyToDeploy() throws {
        try mutateSelectedWallet { wallet in
            try wallet.markReadyToDeploy()
        }
    }

    public func markDeploymentAcceptedByBlockchain() throws {
        try mutateSelectedWallet { wallet in
            try wallet.markDeploymentAcceptedByBlockchain()
        }
    }

    public func markDeploymentFailed() throws {
        try mutateSelectedWallet { wallet in
            try wallet.markDeploymentFailed()
        }
    }

    public func markDeploymentSuccess() throws {
        try mutateSelectedWallet { wallet in
            try wallet.markDeploymentSuccess()
        }
    }

    public func abortDeployment() throws {
        try mutateSelectedWallet { wallet in
            try wallet.abortDeployment()
        }
    }

    public func finishDeployment() throws {
        try mutateSelectedWallet { wallet in
            try wallet.finishDeployment()
        }
    }

    private func mutateSelectedWallet(_ closure: (Wallet) throws -> Void) throws {
        try notifyWalletStateChangesAfter {
            let wallet = try findSelectedWallet()
            try closure(wallet)
            try DomainRegistry.walletRepository.save(wallet)
        }
    }

    private func findSelectedWallet() throws -> Wallet {
        var savedPortfolio: Portfolio?
        do {
            savedPortfolio = try DomainRegistry.portfolioRepository.portfolio()
        } catch let error {
            ApplicationServiceRegistry.logger.error("Failed to fetch portfolio: \(error)")
            throw error
        }
        guard let portfolio = savedPortfolio, let walletID = portfolio.selectedWallet else {
            throw Error.selectedWalletNotFound
        }
        var savedWallet: Wallet?
        do {
            savedWallet = try DomainRegistry.walletRepository.findByID(walletID)
        } catch let error {
            ApplicationServiceRegistry.logger.error("Failed to fetch wallet \(walletID): \(error)")
            throw error
        }
        guard let wallet = savedWallet else {
            throw Error.selectedWalletNotFound
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
        do {
            let wallet = try findSelectedWallet()
            return wallet.owner(kind: type.kind) != nil
        } catch let e {
            ApplicationServiceRegistry.logger.error("Failed to check if owner exists (\(type))", error: e)
        }
        return false
    }

    public func addOwner(address: String, type: OwnerType) throws {
        try mutateSelectedWallet { wallet in
            let owner = Wallet.createOwner(address: address)
            if wallet.owner(kind: type.kind) != nil {
                try wallet.replaceOwner(with: owner, kind: type.kind)
            } else {
                try wallet.addOwner(owner, kind: type.kind)
            }
            if wallet.status == .newDraft {
                let enoughOwnersExist = OwnerType.all.reduce(true) { isEnough, type in
                    isEnough && wallet.owner(kind: type.kind) != nil
                }
                if enoughOwnersExist {
                    try wallet.markReadyToDeploy()
                }
            }
        }
    }

    public func addBrowserExtensionOwner(address: String, browserExtensionCode: String) throws {
        let deviceOwnerAddress = ownerAddress(of: .thisDevice)!
        let signature = try blockchainService.sign(message: "GNO" + address, by: deviceOwnerAddress)
        let browserExtension = try BrowserExtensionCode(json: browserExtensionCode)
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
        try addOwner(address: address, type: .browserExtension)
    }

    public func ownerAddress(of type: OwnerType) -> String? {
        do {
            let wallet = try findSelectedWallet()
            if let owner = wallet.owner(kind: type.kind) {
                return owner.address.value
            }
        } catch let e {
            ApplicationServiceRegistry.logger.error("Failed to fetch owner's address (\(type))", error: e)
        }
        return nil
    }

    // MARK: - Accounts

    public func accountBalance(token: String) -> Int? {
        do {
            let account = try findAccount(token)
            return account.balance
        } catch {
            return nil
        }
    }

    private func updateMinimumFunding(account token: String, amount: Int) throws {
        try assertCanChangeAccount()
        try mutateAccount(token: token) { account in
            account.updateMinimumTransactionAmount(amount)
        }
    }

    private func assertCanChangeAccount() throws {
        try assertTrue(selectedWalletState.isValidForAccountUpdate, Error.invalidWalletState)
    }

    public func update(account token: String, newBalance: Int) throws {
        try assertCanChangeAccount()
        try mutateAccount(token: token) { account in
            account.update(newAmount: newBalance)
        }
    }

    private func mutateAccount(token: String, closure: (Account) throws -> Void) throws {
        try notifyWalletStateChangesAfter {
            let account = try findAccount(token)
            try closure(account)
            try DomainRegistry.accountRepository.save(account)
        }
    }

    private func findAccount(_ token: String) throws -> Account {
        let wallet = try findSelectedWallet()
        do {
            guard let account = try DomainRegistry
                .accountRepository.find(id: AccountID(token: token), walletID: wallet.id) else {
                    throw Error.accountNotFound
            }
            return account
        } catch let error {
            ApplicationServiceRegistry.logger
                .error("Failed to to find account \(token) for wallet \(wallet.id) in account repository: \(error)")
            throw error
        }
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
        guard let pushToken = tokensService.pushToken() else { return }
        let signature = EthSignature(r: "", s: "", v: 27)
        let authRequest = AuthRequest(pushToken: pushToken, signature: signature)
        do {
            try notificationService.auth(request: authRequest)
        } catch JSONHTTPClient.Error.networkRequestFailed(_, _, _) {
            throw Error.networkError
        }
    }

}
