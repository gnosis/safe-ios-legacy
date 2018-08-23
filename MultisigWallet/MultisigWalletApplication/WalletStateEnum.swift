//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public enum WalletState1 {

    case draft
    case deploying
    case notEnoughFunds
    case creationStarted
    case finalizingDeployment
    case readyToUse

    init(_ state: WalletState) {
        switch state {
        case is DraftState: self = .draft
        case is DeployingState: self = .deploying
        case is NotEnoughFundsState: self = .notEnoughFunds
        case is CreationStartedState: self = .creationStarted
        case is FinalizingDeploymentState: self = .finalizingDeployment
        case is ReadyToUseState: self = .readyToUse
        default: preconditionFailure("Unknown wallet state")
        }
    }

}
