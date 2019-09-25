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

    // NOTE: values of this enum used in the database. If you update them, then DB migration is needed.
    // Adding new values are OK as long as you don't touch the old ones.
    public enum State: Int {
        case draft = 0
        case deploying = 1
        case notEnoughFunds = 2
        case creationStarted = 3
        case finalizingDeployment = 4
        case readyToUse = 5
        case recoveryDraft = 6
        case recoveryInProgress = 7
        case recoveryPostProcessing = 8
        case waitingForFirstDeposit = 9

        static let creationStates: Set<State> = [.draft,
                                                 .deploying,
                                                 .notEnoughFunds,
                                                 .creationStarted,
                                                 .finalizingDeployment,
                                                 .waitingForFirstDeposit]
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

public class WalletEvent: DomainEvent {

    public let walletID: WalletID

    public init(_ id: WalletID) {
        self.walletID = WalletID(id.id)
    }

    public convenience init(_ wallet: Wallet) {
        self.init(wallet.id)
    }

}

public class DeploymentStarted: WalletEvent {}
public class StartedWaitingForFirstDeposit: WalletEvent {}
public class DeploymentAborted: WalletEvent {}
public class WalletTransactionHashIsKnown: WalletEvent {}
public class StartedWaitingForRemainingFeeAmount: WalletEvent {}
public class CreationStarted: WalletEvent {}
public class DeploymentFunded: WalletEvent {}
public class WalletCreated: WalletEvent {}
public class WalletCreationFailed: WalletEvent {}

public class RecoveryStarted: DomainEvent {}
public class RecoveryAborted: DomainEvent {}
public class WalletRecovered: DomainEvent {}
public class WalletRecoveryFailed: DomainEvent {}

public class DraftState: WalletState {

    override public var state: WalletState.State { return .draft }

    override var isCreationInProgress: Bool { return false }
    override var canChangeOwners: Bool { return true }
    override var canChangeAddress: Bool { return true }

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

        let confirmations = ownerCount - (requiredRoles.count - 1) // .thisDevice + all other factors
        precondition(confirmations == 1 || confirmations == 2, "Invalid confirmation count during creation")
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
        DomainRegistry.eventPublisher.publish(DeploymentStarted(wallet))
    }

    override func proceed() {
        wallet.state = wallet.waitingForFirstDepositState
        DomainRegistry.walletRepository.save(wallet)
        wallet.state.resume()
    }

    override func cancel() {
        wallet.state = wallet.newDraftState
        wallet.reset()
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(DeploymentAborted(wallet))
    }

}

public class WaitingForFirstDepositState: WalletState {

    override public var state: WalletState.State { return .waitingForFirstDeposit }

    override var isCreationInProgress: Bool { return true }

    override func resume() {
        DomainRegistry.eventPublisher.publish(StartedWaitingForFirstDeposit(wallet))
    }

    override func proceed() {
        guard let minimumBalance = wallet.minimumDeploymentTransactionAmount else {
            preconditionFailure("Minimum balance must be set before waiting for first deposit")
        }
        let token = wallet.feePaymentTokenAddress ?? Token.Ether.address
        let accountID = AccountID(tokenID: TokenID(token.value), walletID: wallet.id)
        let balance = DomainRegistry.accountRepository.find(id: accountID)?.balance ?? 0
        wallet.state = balance < minimumBalance ? wallet.notEnoughFundsState : wallet.creationStartedState
        DomainRegistry.walletRepository.save(wallet)
        wallet.state.resume()
    }

    override func cancel() {
        wallet.state = wallet.newDraftState
        wallet.reset()
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(DeploymentAborted(wallet))
    }

}

public class NotEnoughFundsState: WalletState {

    override public var state: WalletState.State { return .notEnoughFunds }

    override var isCreationInProgress: Bool { return true }

    override func resume() {
        DomainRegistry.eventPublisher.publish(StartedWaitingForRemainingFeeAmount(wallet))
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
        DomainRegistry.eventPublisher.publish(DeploymentAborted(wallet))
    }

}

public class CreationStartedState: WalletState {

    override public var state: WalletState.State { return .creationStarted }

    override var isCreationInProgress: Bool { return true }

    override func resume() {
        DomainRegistry.eventPublisher.publish(DeploymentFunded(wallet))
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
        DomainRegistry.eventPublisher.publish(DeploymentAborted(wallet))
    }
}

public class FinalizingDeploymentState: WalletState {

    override public var state: WalletState.State { return .finalizingDeployment }

    override var isCreationInProgress: Bool { return true }
    override var canChangeTransactionHash: Bool { return true }

    override func resume() {
        DomainRegistry.eventPublisher.publish(CreationStarted(wallet))
    }

    override func proceed() {
        wallet.state = wallet.readyToUseState
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(WalletCreated(wallet))
    }

    override func cancel() {
        DomainRegistry.eventPublisher.publish(WalletCreationFailed(wallet))
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
