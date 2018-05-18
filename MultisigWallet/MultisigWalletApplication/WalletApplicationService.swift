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
    }

    public var selectedWalletState: WalletState {
        do {
            let wallet = try findSelectedWallet()
            if wallet.status == .newDraft {
                let allOwnersExist = OwnerType.all.reduce(true) { result, type in isOwnerExists(type) && result }
                if allOwnersExist {
                    return .readyToDeploy
                }
            }
        } catch {
            // TODO: handle errors
        }
        return .none
    }

    public var hasReadyToUseWallet: Bool {
        return false
    }

    public init() {}

    public func createNewDraftWallet() throws {
        let portfolio = try fetchOrCreatePortfolio()
        let wallet = Wallet(id: DomainRegistry.walletRepository.nextID())
        try portfolio.addWallet(wallet.id)
        try DomainRegistry.walletRepository.save(wallet)
        try DomainRegistry.portfolioRepository.save(portfolio)
    }

    private func fetchOrCreatePortfolio() throws -> Portfolio {
        if let result = try DomainRegistry.portfolioRepository.portfolio() {
            return result
        } else {
            return try Portfolio(id: DomainRegistry.portfolioRepository.nextID())
        }
    }

    public func startDeployment() throws {
        let wallet = try findSelectedWallet()
        try assertEqual(selectedWalletState, .readyToDeploy, Error.oneOrMoreOwnersAreMissing)
        try wallet.startDeployment()
        try DomainRegistry.walletRepository.save(wallet)
    }

    private func findSelectedWallet() throws -> Wallet {
        guard let portfolio = try DomainRegistry.portfolioRepository.portfolio(),
            let walletID = portfolio.selectedWallet,
            let wallet = try DomainRegistry.walletRepository.findByID(walletID) else {
                throw Error.selectedWalletNotFound
        }
        return wallet
    }

    public func markDeploymentAcceptedByBlockchain() {}

    public func markDeploymentFailed() {}

    public func markDeploymentSuccess() {}

    public func abortDeployment() {}

    public func updateMinimumFunding(account: String, amount: Int) {}

    public func update(account: String, newBalance: Int) {}

    public func assignBlockchainAddress(_ address: String) {}

    public func subscribe(_ update: @escaping () -> Void) -> String {
        return ""
    }

    public func unsubscribe(subscription: String) {}

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

}
