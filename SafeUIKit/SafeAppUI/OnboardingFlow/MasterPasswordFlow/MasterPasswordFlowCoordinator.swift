//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

typealias MasterPasswordFlowCompletion = () -> Void

final class MasterPasswordFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        pushController(StartViewController.create(delegate: self))
    }

}

extension MasterPasswordFlowCoordinator: StartViewControllerDelegate {

    func didStart() {
        pushController(SetPasswordViewController.create(delegate: self))
    }

}

extension MasterPasswordFlowCoordinator: SetPasswordViewControllerDelegate {

    func didSetPassword(_ password: String) {
        pushController(ConfirmPaswordViewController.create(referencePassword: password, delegate: self))
    }

}

extension MasterPasswordFlowCoordinator: ConfirmPasswordViewControllerDelegate {

    func didConfirmPassword() {
        exitFlow()
    }

}
