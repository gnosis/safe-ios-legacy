//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public enum WalletStateId {

    case draft
    case deploying
    case waitingForFirstDeposit
    case notEnoughFunds
    case creationStarted
    case transactionHashIsKnown
    case finalizingDeployment
    case readyToUse
    case recoveryDraft
    case recoveryInProgress
    case recoveryPostProcessing

    init(_ state: WalletState) {
        switch state {
        case is DraftState: self = .draft
        case is DeployingState: self = .deploying
        case is WaitingForFirstDepositState: self = .waitingForFirstDeposit
        case is NotEnoughFundsState: self = .notEnoughFunds
        case is CreationStartedState: self = .creationStarted
        case is FinalizingDeploymentState: self = .finalizingDeployment
        case is ReadyToUseState: self = .readyToUse
        case is RecoveryDraftState: self = .recoveryDraft
        case is RecoveryInProgressState: self = .recoveryInProgress
        case is RecoveryPostProcessingState: self = .recoveryPostProcessing
        default: preconditionFailure("Unknown wallet state")
        }
    }

}
