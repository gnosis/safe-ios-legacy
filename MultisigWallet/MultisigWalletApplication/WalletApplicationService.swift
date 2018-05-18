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
        } catch {
            // TODO: handle errors
        }
        return .none
    }

    public var hasReadyToUseWallet: Bool {
        return selectedWalletState == .readyToUse
    }
    
    private static let validAccountUpdateStates: [WalletState] = [
        .addressKnown, .readyToUse, .notEnoughFunds, .accountFunded, .deploymentAcceptedByBlockchain,
        .deploymentSuccess, .deploymentFailed]

    public init() {}

    public func createNewDraftWallet() throws {
        let portfolio = try fetchOrCreatePortfolio()
        let wallet = Wallet(id: DomainRegistry.walletRepository.nextID())
        let account = Account(id: AccountID(token: "ETH"), walletID: wallet.id, balance: 0, minimumAmount: 0)
        try portfolio.addWallet(wallet.id)
        try DomainRegistry.walletRepository.save(wallet)
        try DomainRegistry.portfolioRepository.save(portfolio)
        try DomainRegistry.accountRepository.save(account)
    }

    private func fetchOrCreatePortfolio() throws -> Portfolio {
        if let result = try DomainRegistry.portfolioRepository.portfolio() {
            return result
        } else {
            return try Portfolio(id: DomainRegistry.portfolioRepository.nextID())
        }
    }

    public func isOwnerExists(_ type: OwnerType) -> Bool {
        do {
            let wallet = try findSelectedWallet()
            return wallet.owner(kind: type.kind) != nil
        } catch {
            // TODO: handle error
        }
        return false
    }

    public func addOwner(address: String, type: OwnerType) throws {
        let wallet = try findSelectedWallet()
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
        try DomainRegistry.walletRepository.save(wallet)
    }

    public func ownerAddress(of type: OwnerType) -> String? {
        do {
            let wallet = try findSelectedWallet()
            if let owner = wallet.owner(kind: type.kind) {
                return owner.address.value
            }
        } catch {
            // TODO: log error
        }
        return nil
    }


    private func findSelectedWallet() throws -> Wallet {
        guard let portfolio = try DomainRegistry.portfolioRepository.portfolio(),
            let walletID = portfolio.selectedWallet,
            let wallet = try DomainRegistry.walletRepository.findByID(walletID) else {
                throw Error.selectedWalletNotFound
        }
        return wallet
    }

    public func updateMinimumFunding(account token: String, amount: Int) throws {
        try assertCanChangeAccount()
        let account = try findAccount(token)
        account.updateMinimumTransactionAmount(amount)
        try DomainRegistry.accountRepository.save(account)
    }

    private func findAccount(_ token: String) throws -> Account {
        let wallet = try findSelectedWallet()
        guard let account = try DomainRegistry.accountRepository.find(id: AccountID(token: token),
                                                                      walletID: wallet.id) else {
            throw Error.accountNotFound
        }
        return account
    }

    private func assertCanChangeAccount() throws {
        try assertTrue(WalletApplicationService.validAccountUpdateStates.contains(selectedWalletState),
                       Error.invalidWalletState)
    }
    public func update(account token: String, newBalance: Int) throws {
        try assertCanChangeAccount()
        let account = try findAccount(token)
        account.update(newAmount: newBalance)
        try DomainRegistry.accountRepository.save(account)
    }

    public func assignBlockchainAddress(_ address: String) throws {
        try mutateSelectedWallet { wallet in
            try wallet.changeBlockchainAddress(BlockchainAddress(value: address))
        }
    }

    private func mutateSelectedWallet(_ closure: (Wallet) throws -> Void) throws {
        let wallet = try findSelectedWallet()
        try closure(wallet)
        try DomainRegistry.walletRepository.save(wallet)
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

    public func subscribe(_ update: @escaping () -> Void) -> String {
        return ""
    }

    public func unsubscribe(subscription: String) {}



}
