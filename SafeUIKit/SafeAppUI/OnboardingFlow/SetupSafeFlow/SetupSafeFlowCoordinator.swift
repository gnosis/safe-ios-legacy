//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

public final class SetupSafeFlowCoordinator: FlowCoordinator {

    let newSafeFlowCoordinator = NewSafeFlowCoordinator()

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
}

extension SetupSafeFlowCoordinator: SetupSafeOptionsDelegate {

    func didSelectNewSafe() {
        push(GuidelinesViewController.create(delegate: self))
    }

}

extension SetupSafeFlowCoordinator: GuidelinesViewControllerDelegate {

    public func didPressNext() {
        enterNewSafeFlow()
    }

}
