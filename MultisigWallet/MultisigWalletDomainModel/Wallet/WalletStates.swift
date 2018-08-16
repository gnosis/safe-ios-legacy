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
    }

    override func cancel() {
        wallet.state = wallet.readyToDeployState
    }

}

class NotEnoughFundsState: WalletState {

    override func proceed() {
        wallet.state = wallet.accountFundedState
    }

    override func cancel() {
        wallet.state = wallet.readyToDeployState
    }

}

class AccountFundedState: WalletState {

    override func proceed() {
        wallet.state = wallet.finalizingDeploymentState
    }

    override func cancel() {
        wallet.state = wallet.readyToDeployState
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
        wallet.state = wallet.readyToDeployState
    }

}

class ReadyToUseState: WalletState {

    override init(wallet: Wallet) {
        super.init(wallet: wallet)
        canChangeOwners = true
    }

}
