//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ChangePasswordFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        let vc = VerifyCurrentPasswordViewController.create(delegate: self)
        push(vc)
    }

}

extension ChangePasswordFlowCoordinator: VerifyCurrentPasswordViewControllerDelegate {

    func didVerifyPassword() {}

}
