//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import ReplaceBrowserExtensionUI
import ReplaceBrowserExtensionFacade
import MultisigWalletApplication

class ReplaceBrowserExtensionFlowCoordinator: FlowCoordinator {

    weak var introVC: RBEIntroViewController?
    var transactionID: RBETransactionID!

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
        self.transactionID = introVC!.transactionID
        let controller = PairWithBrowserExtensionViewController.createRBEConnectController(delegate: self)
        push(controller)
    }

}

extension ReplaceBrowserExtensionFlowCoordinator: PairWithBrowserExtensionViewControllerDelegate {

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didScanAddress address: String,
                                                code: String) throws {
        try ApplicationServiceRegistry.settingsService.connect(transaction: transactionID, code: code)
    }

    // did go back -> delete pair request

    func pairWithBrowserExtensionViewControllerDidFinish() {
        print("Finished successfullly")
    }

}
