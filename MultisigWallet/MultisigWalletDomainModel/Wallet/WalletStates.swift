//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Base class implementing State design pattern, where every state of the wallet expressed in a separate class.
/// This allows to remove switches and if-else conditionals throughout the codebase and instead use polymorphism
/// to invoke different behavior, depending on the current state.
/// WalletState is used to represent a specific step in the wallet deployment process, so that state could be
/// persisted and reloaded even between application launches.
class WalletState {

    var canChangeOwners: Bool = false
    var canChangeTransactionHash: Bool = false
    var canChangeAddress: Bool = false

    internal weak var wallet: Wallet!

    init(wallet: Wallet) {
        self.wallet = wallet
    }

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

class DraftState: WalletState {

    override init(wallet: Wallet) {
        super.init(wallet: wallet)
        canChangeOwners = true
    }

    override func proceed() {
        wallet.state = wallet.deployingState
        if wallet.status == .newDraft {
            wallet.markReadyToDeploy()
            wallet.startDeployment()
        }
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(DeploymentStarted())
    }

}

class DeploymentStarted: DomainEvent {}

class DeployingState: WalletState {

    override init(wallet: Wallet) {
        super.init(wallet: wallet)
        canChangeAddress = true
    }

    override func proceed() {
        wallet.state = wallet.notEnoughFundsState
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(WalletConfigured())
    }

    override func cancel() {
        wallet.state = wallet.newDraftState
    }

}

class WalletConfigured: DomainEvent {}

class NotEnoughFundsState: WalletState {

    override func proceed() {
        wallet.state = wallet.accountFundedState
    }

    override func cancel() {
        wallet.state = wallet.newDraftState
    }

}

class AccountFundedState: WalletState {

    override func proceed() {
        wallet.state = wallet.finalizingDeploymentState
    }

    override func cancel() {
        wallet.state = wallet.newDraftState
    }

}

class FinalizingDeploymentState: WalletState {

    override init(wallet: Wallet) {
        super.init(wallet: wallet)
        canChangeTransactionHash = true
    }

    override func proceed() {
        wallet.state = wallet.readyToUseState

    }

    override func cancel() {
        wallet.state = wallet.newDraftState
    }

}

class ReadyToUseState: WalletState {

    override init(wallet: Wallet) {
        super.init(wallet: wallet)
        canChangeOwners = true
    }

}
