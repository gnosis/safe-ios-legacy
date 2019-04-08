//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessApplication

final class ChangePasswordFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        let vc = VerifyCurrentPasswordViewController.create(delegate: self)
        push(vc)
    }

}

extension ChangePasswordFlowCoordinator: VerifyCurrentPasswordViewControllerDelegate {

    func didVerifyPassword() {
        let vc = SetupNewPasswordViewController.create(delegate: self)
        push(vc)
    }

}

extension ChangePasswordFlowCoordinator: SetupNewPasswordViewControllerDelegate {

    func didEnterNewPassword(_ password: String) {
        do {
            try Authenticator.instance.updateUserPassword(with: password)
            exitFlow()
        } catch {
            ErrorHandler.showFatalError(log: "Failed to update password", error: error)
        }
    }

}
