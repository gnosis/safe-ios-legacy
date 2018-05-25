//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

public class WalletApplicationService: Assertable {

    public enum WalletState {
        case none
        case newDraft
        case readyToDeploy
        case deploymentStarted
        case addressKnown
        case accountFunded
        case notEnoughFunds
        case deploymentAcceptedByBlockchain
        case deploymentSuccess
        case deploymentFailed
        case readyToUse
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

    enum Error: String, LocalizedError, Hashable {
        case oneOrMoreOwnersAreMissing
        case selectedWalletNotFound
        case invalidWalletState
        case accountNotFound
    }

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
                if account.minimumTransactionAmount == 0 &&
                    account.balance == 0 {
                    return .addressKnown
                } else if account.balance < account.minimumTransactionAmount {
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
        return selectedWalletState == .readyToUse
    }

    private static let validAccountUpdateStates: [WalletState] = [
        .addressKnown, .readyToUse, .notEnoughFunds, .accountFunded, .deploymentAcceptedByBlockchain,
        .deploymentSuccess, .deploymentFailed]
    private var statusUpdateHandlers = [String: () -> Void]()

    public init() {}

    // MARK: - Wallet

    public func createNewDraftWallet() throws {
        try notifyWalletStateChangesAfter {
            let portfolio = try fetchOrCreatePortfolio()
            let address = try DomainRegistry.blockchainService.generateExternallyOwnedAccount()
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

    public func assignBlockchainAddress(_ address: String) throws {
        try mutateSelectedWallet { wallet in
            try wallet.changeBlockchainAddress(BlockchainAddress(value: address))
        }
    }

    public func startDeployment() throws {
        try mutateSelectedWallet { wallet in
            try wallet.startDeployment()
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
        guard let portfolio = try DomainRegistry.portfolioRepository.portfolio(),
            let walletID = portfolio.selectedWallet,
            let wallet = try DomainRegistry.walletRepository.findByID(walletID) else {
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
            try wallet.addOwner(owner, kind: type.kind)
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

    public func updateMinimumFunding(account token: String, amount: Int) throws {
        try assertCanChangeAccount()
        try mutateAccount(token: token) { account in
            account.updateMinimumTransactionAmount(amount)
        }
    }

    private func assertCanChangeAccount() throws {
        try assertTrue(WalletApplicationService.validAccountUpdateStates.contains(selectedWalletState),
                       Error.invalidWalletState)
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
        guard let account = try DomainRegistry.accountRepository.find(id: AccountID(token: token),
                                                                      walletID: wallet.id) else {
                                                                        throw Error.accountNotFound
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

}
