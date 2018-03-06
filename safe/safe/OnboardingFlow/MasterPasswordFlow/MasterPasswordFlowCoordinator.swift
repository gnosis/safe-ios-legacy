//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

class MasterPasswordFlowCoordinator {

    var account: AccountProtocol = Account.shared
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
        let vc = ConfirmPaswordViewController.create(referencePassword: password, delegate: self)
        masterPasswordNavigationController.show(vc, sender: nil)
    }

}

extension MasterPasswordFlowCoordinator: ConfirmPasswordViewControllerDelegate {

    func didConfirmPassword(_ password: String) {
        account.cleanupAllData()
        do {
            try account.setMasterPassword(password)
        } catch {
            // TODO: 06/03/18: handle error
        }
        let vc = PasswordSuccessViewController()
        masterPasswordNavigationController.show(vc, sender: nil)
    }

}
