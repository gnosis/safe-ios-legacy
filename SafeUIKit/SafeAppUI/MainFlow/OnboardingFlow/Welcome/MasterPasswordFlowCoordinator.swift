//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

typealias MasterPasswordFlowCompletion = () -> Void

final class MasterPasswordFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        push(PasswordViewController.create(delegate: self))
    }

}

extension MasterPasswordFlowCoordinator: PasswordViewControllerDelegate {

    func didSetPassword(_ password: String) {
        push(PasswordViewController.create(delegate: self, referencePassword: password))
    }

    func didConfirmPassword() {
        exitFlow()
    }

}
