//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

public final class SetupSafeFlowCoordinator: FlowCoordinator {

    let newSafeFlowCoordinator = NewSafeFlowCoordinator()
    let recoverSafeFlowCoordinator = RecoverSafeFlowCoordinator()

    public override func setUp() {
        super.setUp()
        push(SetupSafeOptionsViewController.create(delegate: self))

        if newSafeFlowCoordinator.isSafeCreationInProgress ||
            ApplicationServiceRegistry.walletService.isWalletDeployable {
            enterNewSafeFlow()
        }
    }

    private func enterNewSafeFlow() {
        enter(flow: newSafeFlowCoordinator) { [unowned self] in
            self.exitFlow()
        }
    }

    private func enterRecoverSafeFlow() {
        enter(flow: recoverSafeFlowCoordinator) { [unowned self] in
            self.exitFlow()
        }
    }
}

extension SetupSafeFlowCoordinator: SetupSafeOptionsDelegate {

    func didSelectNewSafe() {
        enterNewSafeFlow()
    }

    func didSelectRecoverSafe() {
        enterRecoverSafeFlow()
    }

}
