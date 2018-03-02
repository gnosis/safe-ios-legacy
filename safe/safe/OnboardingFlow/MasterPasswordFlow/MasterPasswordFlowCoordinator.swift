//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

class MasterPasswordFlowCoordinator {

    private var masterPasswordNavigationController: MasterPasswordNavigationController!

    func startViewController() -> UIViewController {
        let startVC = StartViewController.create(delegate: self)
        masterPasswordNavigationController = MasterPasswordNavigationController.create(startVC)
        return masterPasswordNavigationController
    }

}

extension MasterPasswordFlowCoordinator: StartViewControllerDelegate {

    func didStart() {
        let vc = SetPasswordViewController.create(delegate: self)
        masterPasswordNavigationController.show(vc, sender: nil)
    }

}

extension MasterPasswordFlowCoordinator: SetPasswordViewControllerDelegate {

    func didSetPassword(_ password: String) {
        let vc = ConfirmPaswordViewController.create(referencePassword: password)
        masterPasswordNavigationController.show(vc, sender: nil)
    }

}
