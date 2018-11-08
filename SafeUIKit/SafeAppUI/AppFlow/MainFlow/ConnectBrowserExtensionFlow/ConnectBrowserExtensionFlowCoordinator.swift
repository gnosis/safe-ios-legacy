//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ConnectBrowserExtensionFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        let pairController = PairWithBrowserExtensionViewController.create { [unowned self] address, code in
            self.didPair()
        }
        push(pairController)
    }

    private func didPair() {
        push(UIViewController())
    }

}
