//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ChangePasswordFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        let vc = VerifyCurrentPasswordViewController()
        vc.delegate = self
        push(vc)
    }

}

extension ChangePasswordFlowCoordinator: VerifyCurrentPasswordViewControllerDelegate {}
