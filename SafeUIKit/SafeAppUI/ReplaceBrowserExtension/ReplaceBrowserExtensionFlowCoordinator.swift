//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import ReplaceBrowserExtensionUI

class ReplaceBrowserExtensionFlowCoordinator: FlowCoordinator {

    weak var introVC: RBEIntroViewController?

    override func setUp() {
        super.setUp()
        let intro = RBEIntroViewController.create()
        push(intro)
        introVC = intro
    }

}
