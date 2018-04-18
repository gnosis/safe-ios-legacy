//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class NewSafeFlowCoordinator: FlowCoordinator {

    let paperWalletFlowCoordinator = PaperWalletFlowCoordinator()
    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }

    private var startVC: UIViewController!
    private lazy var draftSafe = try? identityService.getOrCreateDraftSafe()

    override init() {
        super.init()
        paperWalletFlowCoordinator.completion = paperWalletSetupCompletion
        paperWalletFlowCoordinator.draftSafe = draftSafe
    }

    override func flowStartController() -> UIViewController {
        startVC = NewSafeViewController.create(draftSafe: draftSafe, delegate: self)
        return startVC
    }

    private func paperWalletSetupCompletion() {
        rootVC.popToViewController(startVC, animated: true)
    }

}

extension NewSafeFlowCoordinator: NewSafeDelegate {

    func didSelectPaperWalletSetup() {
        let controller = paperWalletFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(controller, animated: true)
    }

    func didSelectChromeExtensionSetup() {
        let controller = PairWithChromeExtensionViewController()
        rootVC.pushViewController(controller, animated: true)
    }

}
