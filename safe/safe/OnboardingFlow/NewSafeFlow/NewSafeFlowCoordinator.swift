//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class NewSafeFlowCoordinator: FlowCoordinator {

    let paperWalletFlowCoordinator = PaperWalletFlowCoordinator()

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }

    override init() {
        super.init()
        paperWalletFlowCoordinator.completion = paperWalletSetupCompletion
    }

    override func flowStartController() -> UIViewController {
        return NewSafeViewController.create(delegate: self)
    }

    func paperWalletSetupCompletion() {}

}

extension NewSafeFlowCoordinator: NewSafeDelegate {

    func didSelectPaperWalletSetup() {
        let controller = paperWalletFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(controller, animated: true)
    }

}
