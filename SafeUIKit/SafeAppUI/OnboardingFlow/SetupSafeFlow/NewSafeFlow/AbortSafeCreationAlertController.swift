//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class SafeAlertController: UIAlertController {

    static func wrap<T>(closure: @escaping () -> Void) -> (T) -> Void {
        return { _ in closure() }
    }

}

class AbortSafeCreationAlertController: SafeAlertController {

    private struct Strings {

        static let title = LocalizedString("pending_safe.abort_alert.title",
                                           comment: "Title of abort safe creation alert")
        static let message = LocalizedString("pending_safe.abort_alert.message", comment: "Message body of abort alert")
        static let abortTitle = LocalizedString("pending_safe.abort_alert.abort",
                                                comment: "Abort safe creation button title")
        static let continueTitle = LocalizedString("pending_safe.abort_alert.continue",
                                                   comment: "Continue safe creation button title")

    }

    static func create(abort: @escaping () -> Void,
                       continue: @escaping () -> Void) -> AbortSafeCreationAlertController {
        let controller = AbortSafeCreationAlertController(title: Strings.title,
                                                          message: Strings.message,
                                                          preferredStyle: .alert)
        let abortAction = UIAlertAction.create(title: Strings.abortTitle, style: .destructive) { _ in
            ApplicationServiceRegistry.walletService.abortDeployment()
            abort()
        }
        controller.addAction(abortAction)
        let continueAction = UIAlertAction.create(title: Strings.continueTitle,
                                                  style: .cancel,
                                                  handler: wrap(closure: `continue`))
        controller.addAction(continueAction)
        return controller
    }

}
