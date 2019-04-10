//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

class SafeCreationFailedAlertController: SafeAlertController {

    private enum Strings {

        static let title = LocalizedString("pending_safe.failed_alert.title",
                                           comment: "Pending safe failed alert's title")
        static let message = LocalizedString("pending_safe.failed_alert.message",
                                             comment: "Pending safe failed alert's message")
        static let okTitle = LocalizedString("pending_safe.failed_alert.ok", comment: "OK button title")

    }

    static func create(localizedErrorDescription message: String,
                       ok: @escaping () -> Void) -> SafeCreationFailedAlertController {
        let controller = SafeCreationFailedAlertController(title: Strings.title,
                                                           message: String(format: Strings.message, message),
                                                           preferredStyle: .alert)
        let okAction = UIAlertAction.create(title: Strings.okTitle, style: .cancel, handler: wrap(closure: ok))
        controller.addAction(okAction)
        return controller
    }

}
