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
        push(intro)
        introVC = intro
    }

}
