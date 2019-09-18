//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public extension AuthenticatorViewController {

    static func createRBEConnectController(delegate: TwoFAViewControllerDelegate)
        -> AuthenticatorViewController {
            let controller = AuthenticatorViewController.create(delegate: delegate)
            controller.screenTitle = nil
            controller.screenHeader = LocalizedString("scan_qr_code", comment: "Scan QR code")
            controller.descriptionText = LocalizedString("pairing_info", comment: "Replace BE pairing description.")
            controller.hidesSkipButton = true
            return controller
    }

}
