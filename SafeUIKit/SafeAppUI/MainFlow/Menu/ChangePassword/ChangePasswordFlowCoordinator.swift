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
            push(SuccessViewController.changePasswordSuccess(action: exitFlow))
        } catch {
            ErrorHandler.showFatalError(log: "Failed to update password",
                                        error: error,
                                        from: navigationController.topViewController!)
        }
    }

}

extension SuccessViewController {

    static func changePasswordSuccess(action: @escaping () -> Void) -> SuccessViewController {
        return .congratulations(text: LocalizedString("password_changed", comment: "Explanation text"),
                                image: Asset.congratulations.image,
                                tracking: ChangePasswordTrackingEvent.success,
                                action: action)
    }

}
