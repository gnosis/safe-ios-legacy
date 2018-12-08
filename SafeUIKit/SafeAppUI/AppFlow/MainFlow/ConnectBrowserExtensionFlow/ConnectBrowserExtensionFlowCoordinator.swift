//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ConnectBrowserExtensionFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        let pairController = PairWithBrowserExtensionViewController.create(delegate: self)
        push(pairController)
    }

}

extension ConnectBrowserExtensionFlowCoordinator: PairWithBrowserExtensionViewControllerDelegate {

    func pairWithBrowserExtensionViewControllerDidSkipPairing() {}

    func pairWithBrowserExtensionViewControllerDidPair(to address: String, with code: String) {}

}
