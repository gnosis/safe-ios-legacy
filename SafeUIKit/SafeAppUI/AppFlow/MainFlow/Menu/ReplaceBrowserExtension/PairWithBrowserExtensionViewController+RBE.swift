//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public extension PairWithBrowserExtensionViewController {

    static func createRBEConnectController(delegate: PairWithBrowserExtensionViewControllerDelegate)
        -> PairWithBrowserExtensionViewController {
            let controller = PairWithBrowserExtensionViewController.create(delegate: delegate)
            controller.screenTitle = nil
            controller.screenHeader = LocalizedString("replace_extension.connect.header", comment: "Scan QR Code")
            controller.descriptionText = LocalizedString("replace_extension.connect.description",
                                                         comment: "Description")
            controller.hidesSkipButton = true
            return controller
    }

}
