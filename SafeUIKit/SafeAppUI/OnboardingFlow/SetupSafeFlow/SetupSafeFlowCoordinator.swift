//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

public final class SetupSafeFlowCoordinator: FlowCoordinator {

    private let newSafeFlowCoordinator = NewSafeFlowCoordinator()

    override func setUp() {
        super.setUp()
        push(SetupSafeOptionsViewController.create(delegate: self))
        if ApplicationServiceRegistry.walletService.selectedWalletState == .newDraft {
            enter(flow: newSafeFlowCoordinator)
        }
    }
}

extension SetupSafeFlowCoordinator: SetupSafeOptionsDelegate {

    func didSelectNewSafe() {
        enter(flow: newSafeFlowCoordinator)
    }

}
