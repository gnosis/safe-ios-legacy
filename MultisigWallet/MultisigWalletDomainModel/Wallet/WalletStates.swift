//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Base class implementing State design pattern, where every state of the wallet expressed in a separate class.
/// This allows to remove switches and if-else conditionals throughout the codebase and instead use polymorphism
/// to invoke different behavior, depending on the current state.
/// WalletState is used to represent a specific step in the wallet deployment process, so that state could be
/// persisted and reloaded even between application launches.
public class WalletState {

    public enum State: Int {
        case draft
        case deploying
        case notEnoughFunds
        case creationStarted
        case finalizingDeployment
        case readyToUse
    }

    public var state: State { preconditionFailure("Not implemented") }

    var canChangeOwners: Bool = false
    var canChangeTransactionHash: Bool = false
    var canChangeAddress: Bool = false
    var isDeployable: Bool { return false }

    internal weak var wallet: Wallet!

    init(wallet: Wallet) {
        self.wallet = wallet
    }

    /// Republishes event that led to the current state.
    func resume() {}

    /// Moves wallet to the next state in the deployment process. Implemented in subclasses
    func proceed() {}

    /// Cancels current state. Implemented in subclasses
    func cancel() {}

}

extension WalletState: CustomStringConvertible {

    public var description: String {
        return String(describing: type(of: self))
    }

}

public class DraftState: WalletState {

    override public var state: WalletState.State { return .draft }

    private let requiredRoles = [OwnerRole.thisDevice, .paperWallet, .paperWalletDerived]

    private var hasAllRoles: Bool {
        return requiredRoles.reduce(true) { $0 && wallet.owner(role: $1) != nil }
    }

    override var isDeployable: Bool {
        return hasAllRoles
    }

    override init(wallet: Wallet) {
        super.init(wallet: wallet)
        canChangeOwners = true
    }

    override func resume() {
        let ownerCount = wallet.allOwners().count
        guard hasAllRoles, ownerCount <= 4 else {
            preconditionFailure("Wallet is misconfigured. Must have all roles set up.")
        }
        let confirmations = wallet.owner(role: .browserExtension) == nil ? 1 : 2
        wallet.changeConfirmationCount(confirmations)
        proceed()
    }

    override func proceed() {
        wallet.state = wallet.deployingState
        DomainRegistry.walletRepository.save(wallet)
        wallet.state.resume()
    }

}

public class DeploymentStarted: DomainEvent {}
public class DeploymentAborted: DomainEvent {}

public class DeployingState: WalletState {

    override public var state: WalletState.State { return .deploying }

    override init(wallet: Wallet) {
        super.init(wallet: wallet)
        canChangeAddress = true
    }

    override func resume() {
        DomainRegistry.eventPublisher.publish(DeploymentStarted())
    }

    override func proceed() {
        wallet.state = wallet.notEnoughFundsState
        DomainRegistry.walletRepository.save(wallet)
        wallet.state.resume()
    }

    override func cancel() {
        wallet.state = wallet.newDraftState
        wallet.reset()
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(DeploymentAborted())
    }

}

public class WalletConfigured: DomainEvent {}

public class NotEnoughFundsState: WalletState {

    override public var state: WalletState.State { return .notEnoughFunds }

    override func resume() {
        DomainRegistry.eventPublisher.publish(WalletConfigured())
    }

    override func proceed() {
        wallet.state = wallet.creationStartedState
        DomainRegistry.walletRepository.save(wallet)
        wallet.state.resume()
    }

    override func cancel() {
        wallet.state = wallet.newDraftState
        wallet.reset()
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(DeploymentAborted())
    }

}

public class DeploymentFunded: DomainEvent {}

public class CreationStartedState: WalletState {

    override public var state: WalletState.State { return .creationStarted }

    override func resume() {
        DomainRegistry.eventPublisher.publish(DeploymentFunded())
    }

    override func proceed() {
        wallet.state = wallet.finalizingDeploymentState
        DomainRegistry.walletRepository.save(wallet)
        wallet.state.resume()
    }

    override func cancel() {
        wallet.state = wallet.newDraftState
        wallet.reset()
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(DeploymentAborted())
    }
}

public class CreationStarted: DomainEvent {}
public class WalletTransactionHashIsKnown: DomainEvent {}

public class FinalizingDeploymentState: WalletState {

    override public var state: WalletState.State { return .finalizingDeployment }

    override init(wallet: Wallet) {
        super.init(wallet: wallet)
        canChangeTransactionHash = true
    }

    override func resume() {
        DomainRegistry.eventPublisher.publish(CreationStarted())
    }

    override func proceed() {
        wallet.state = wallet.readyToUseState
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(WalletCreated())
    }

    override func cancel() {
        wallet.state = wallet.newDraftState
        wallet.reset()
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(WalletCreationFailed())
    }

}

public class WalletCreated: DomainEvent {}
public class WalletCreationFailed: DomainEvent {}

public class ReadyToUseState: WalletState {

    override public var state: WalletState.State { return .readyToUse }

    override init(wallet: Wallet) {
        super.init(wallet: wallet)
        canChangeOwners = true
    }

}
