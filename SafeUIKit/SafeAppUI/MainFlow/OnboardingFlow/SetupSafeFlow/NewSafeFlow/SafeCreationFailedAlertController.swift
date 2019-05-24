//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

class SafeCreationFailedAlertController: SafeAlertController {

    private enum Strings {

        static let title = LocalizedString("error",
                                           comment: "Pending safe failed alert's title")
        static let message = LocalizedString("ios_creationFee_failed_error",
                                             comment: "Pending safe failed alert's message")
        static let okTitle = LocalizedString("ok", comment: "OK button title")

    }

    static func create(message: String, ok: @escaping () -> Void = {}) -> SafeCreationFailedAlertController {
        let controller = SafeCreationFailedAlertController(title: Strings.title,
                                                           message: String(format: Strings.message, message),
                                                           preferredStyle: .alert)
        let okAction = UIAlertAction.create(title: Strings.okTitle, style: .cancel, handler: wrap(closure: ok))
        controller.addAction(okAction)
        return controller
    }

}
