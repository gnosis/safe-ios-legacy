//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class NewSafeFlowCoordinator: FlowCoordinator {

    var paperWalletFlowCoordinator: PaperWalletFlowCoordinator!
    var pairWithBrowserExtensionFlowCoordinator: PairWithBrowserExtensionFlowCoordinator!

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }
    private var startVC: UIViewController!
    private(set) lazy var draftSafe = try? identityService.getOrCreateDraftSafe()

    override init() {
        super.init()
        paperWalletFlowCoordinator = PaperWalletFlowCoordinator(
            draftSafe: draftSafe,
            completion: paperWalletSetupCompletion)
    }

    override func flowStartController() -> UIViewController {
        startVC = NewSafeViewController.create(draftSafe: draftSafe, delegate: self)
        return startVC
    }

    private func paperWalletSetupCompletion() {
        identityService.confirmPaperWallet(draftSafe: draftSafe!)
        rootVC.popToViewController(startVC, animated: true)
    }

    private func pairWithBrowserExtensionCompletion(extensionAddress: String) {
        identityService.confirmBrowserExtension(draftSafe: draftSafe!, address: extensionAddress)
        rootVC.popToViewController(startVC, animated: true)
    }

}

extension NewSafeFlowCoordinator: NewSafeDelegate {

    func didSelectPaperWalletSetup() {
        let controller = paperWalletFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(controller, animated: true)
    }

    func didSelectBrowserExtensionSetup() {
        pairWithBrowserExtensionFlowCoordinator = PairWithBrowserExtensionFlowCoordinator(
            address: draftSafe?.browserExtensionAddressString,
            completion: pairWithBrowserExtensionCompletion)
        let controller = pairWithBrowserExtensionFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(controller, animated: true)
    }

    func didSelectNext() {
       rootVC.pushViewController(PendingSafeViewController(), animated: false)
    }

}
