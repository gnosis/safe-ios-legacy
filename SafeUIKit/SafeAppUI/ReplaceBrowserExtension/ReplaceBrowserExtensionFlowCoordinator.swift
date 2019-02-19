//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import ReplaceBrowserExtensionUI
import MultisigWalletApplication

class ReplaceBrowserExtensionFlowCoordinator: FlowCoordinator {

    weak var introVC: RBEIntroViewController?

    override func setUp() {
        super.setUp()
        let intro = RBEIntroViewController.create()
        intro.starter = ApplicationServiceRegistry.settingsService
        intro.delegate = self
        push(intro)
        introVC = intro
    }

}

extension ReplaceBrowserExtensionFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        let controller = PairWithBrowserExtensionViewController.create(delegate: self)
        push(controller)
    }

}

extension ReplaceBrowserExtensionFlowCoordinator: PairWithBrowserExtensionViewControllerDelegate {

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didScanAddress address: String,
                                                code: String) {
    }

    func pairWithBrowserExtensionViewControllerDidSkipPairing() {}

    func pairWithBrowserExtensionViewControllerDidFinish() {}

}
