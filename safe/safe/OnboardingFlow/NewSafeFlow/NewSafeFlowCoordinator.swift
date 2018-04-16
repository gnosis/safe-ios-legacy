//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class NewSafeFlowCoordinator: FlowCoordinator {

    let recoveryWithMnemonicFlowCoordinator = RecoveryWithMnemonicFlowCoordinator()

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }

    override init() {
        super.init()
        recoveryWithMnemonicFlowCoordinator.completion = recoveryWithMnemonicCompletion
    }

    override func flowStartController() -> UIViewController {
        return RecoveryOptionsViewController.create(delegate: self)
    }

    func recoveryWithMnemonicCompletion() {}

}

extension NewSafeFlowCoordinator: RecoveryOptionsDelegate {

    func didSelectMnemonicRecovery() {
        let controller = recoveryWithMnemonicFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(controller, animated: true)
    }

}
