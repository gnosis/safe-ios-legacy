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

    var canChangeOwners: Bool = false
    var canChangeTransactionHash: Bool = false
    var canChangeAddress: Bool = false

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

    var description: String {
        return String(describing: type(of: self))
    }

}

public class DraftState: WalletState {

    override init(wallet: Wallet) {
        super.init(wallet: wallet)
        canChangeOwners = true
    }

    override func resume() {
        proceed()
    }

    override func proceed() {
        wallet.state = wallet.deployingState
        if wallet.status == .newDraft {
            wallet.markReadyToDeploy()
            wallet.startDeployment()
        }
        DomainRegistry.walletRepository.save(wallet)
        wallet.state.resume()
    }

}

public class DeploymentStarted: DomainEvent {}

public class DeployingState: WalletState {

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
    }

}

public class WalletConfigured: DomainEvent {}

public class NotEnoughFundsState: WalletState {

    override func resume() {
        DomainRegistry.eventPublisher.publish(WalletConfigured())
    }

    override func proceed() {
        wallet.state = wallet.creationStartedState
        if wallet.status == .addressKnown {
            wallet.markDeploymentAcceptedByBlockchain()
        }
        DomainRegistry.walletRepository.save(wallet)
        wallet.state.resume()
    }

    override func cancel() {
        wallet.state = wallet.newDraftState
    }

}

public class DeploymentFunded: DomainEvent {}

public class CreationStartedState: WalletState {

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
    }
}

public class CreationStarted: DomainEvent {}

public class FinalizingDeploymentState: WalletState {

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
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(WalletCreationFailed())
    }

}

public class WalletCreated: DomainEvent {}
public class WalletCreationFailed: DomainEvent {}

public class ReadyToUseState: WalletState {

    override init(wallet: Wallet) {
        super.init(wallet: wallet)
        canChangeOwners = true
    }

}
