//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import Crashlytics

typealias MasterPasswordFlowCompletion = () -> Void

final class MasterPasswordFlowCoordinator: FlowCoordinator {

    var completion: MasterPasswordFlowCompletion?

    override func flowStartController() -> UIViewController {
        return StartViewController.create(delegate: self)
    }

}

extension MasterPasswordFlowCoordinator: StartViewControllerDelegate {

    func didStart() {
        let vc = SetPasswordViewController.create(delegate: self)
        print(rootVC)
        rootVC.show(vc, sender: nil)
    }

}

extension MasterPasswordFlowCoordinator: SetPasswordViewControllerDelegate {

    func didSetPassword(_ password: String) {
        let vc = ConfirmPaswordViewController.create(account: Account.shared,
                                                     referencePassword: password,
                                                     delegate: self)
        rootVC.show(vc, sender: nil)
    }

}

extension MasterPasswordFlowCoordinator: ConfirmPasswordViewControllerDelegate {

    func didConfirmPassword() {
        completion?()
        let vc = PasswordSuccessViewController.create()
        vc.view.backgroundColor = ColorName.gray.color
        rootVC.show(vc, sender: nil)
    }

    func terminate() {
        Crashlytics.sharedInstance().crash()
    }

}
