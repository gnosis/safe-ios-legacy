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
        case recoveryDraft
        case recoveryInProgress
        case recoveryPostProcessing
    }

    public var state: State { preconditionFailure("Not implemented") }

    var canChangeOwners: Bool { return false }
    var canChangeTransactionHash: Bool { return false }
    var canChangeAddress: Bool { return false }
    var isDeployable: Bool { return false }
    var isReadyToUse: Bool { return false }
    var isCreationInProgress: Bool { return false }
    var isRecoveryInProgress: Bool { return false }
    var isFinalizingRecovery: Bool { return false }

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

public class DeploymentStarted: DomainEvent {}
public class DeploymentAborted: DomainEvent {}
public class WalletTransactionHashIsKnown: DomainEvent {}
public class WalletConfigured: DomainEvent {}
public class CreationStarted: DomainEvent {}
public class DeploymentFunded: DomainEvent {}
public class WalletCreated: DomainEvent {}
public class WalletCreationFailed: DomainEvent {}

public class RecoveryStarted: DomainEvent {}
public class RecoveryAborted: DomainEvent {}
public class WalletRecovered: DomainEvent {}
public class WalletRecoveryFailed: DomainEvent {}

public class DraftState: WalletState {

    override public var state: WalletState.State { return .draft }

    override var isCreationInProgress: Bool { return false }
    override var canChangeOwners: Bool { return true }

    private let requiredRoles = [OwnerRole.thisDevice, .paperWallet, .paperWalletDerived]

    private var hasAllRoles: Bool {
        return requiredRoles.reduce(true) { $0 && wallet.owner(role: $1) != nil }
    }

    override var isDeployable: Bool {
        return hasAllRoles
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

public class DeployingState: WalletState {

    override public var state: WalletState.State { return .deploying }

    override var isCreationInProgress: Bool { return true }
    override var canChangeAddress: Bool { return true }

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

public class NotEnoughFundsState: WalletState {

    override public var state: WalletState.State { return .notEnoughFunds }

    override var isCreationInProgress: Bool { return true }

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

public class CreationStartedState: WalletState {

    override public var state: WalletState.State { return .creationStarted }

    override var isCreationInProgress: Bool { return true }

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

public class FinalizingDeploymentState: WalletState {

    override public var state: WalletState.State { return .finalizingDeployment }

    override var isCreationInProgress: Bool { return true }
    override var canChangeTransactionHash: Bool { return true }

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

public class ReadyToUseState: WalletState {

    override public var state: WalletState.State { return .readyToUse }
    override var isReadyToUse: Bool { return true }
    override var isCreationInProgress: Bool { return false }
    override var canChangeOwners: Bool { return true }

}

public class RecoveryDraftState: WalletState {

    public override var state: WalletState.State { return .recoveryDraft }
    override var canChangeOwners: Bool { return true }
    override var canChangeAddress: Bool { return true }

    override func resume() {
        proceed()
    }

    override func proceed() {
        wallet.state = wallet.recoveryInProgressState
        DomainRegistry.walletRepository.save(wallet)
        wallet.state.resume()
    }

}

public class RecoveryInProgressState: WalletState {

    public override var state: WalletState.State { return .recoveryInProgress }
    override var isRecoveryInProgress: Bool { return true }

    override func resume() {
        DomainRegistry.eventPublisher.publish(RecoveryStarted())
    }

    override func proceed() {
        wallet.state = wallet.recoveryPostProcessingState
        DomainRegistry.walletRepository.save(wallet)
        wallet.state.resume()
    }

    override func cancel() {
        wallet.state = wallet.recoveryDraftState
        wallet.reset()
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(RecoveryAborted())
    }

}

public class RecoveryPostProcessingState: WalletState {

    public override var state: WalletState.State { return .recoveryPostProcessing }
    override var isRecoveryInProgress: Bool { return true }
    override var isFinalizingRecovery: Bool { return true }

    override func proceed() {
        wallet.state = wallet.readyToUseState
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(WalletRecovered())
    }

    override func cancel() {
        wallet.state = wallet.recoveryDraftState
        wallet.reset()
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(WalletRecoveryFailed())
    }

}
