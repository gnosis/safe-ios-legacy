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
        static let cancelTitle = LocalizedString("pending_safe.abort_alert.cancel",
                                                 comment: "Continue safe creation button title")

    }

    static func create(abort: @escaping () -> Void,
                       continue: @escaping () -> Void) -> AbortSafeCreationAlertController {
        let controller = AbortSafeCreationAlertController(title: Strings.title,
                                                          message: Strings.message,
                                                          preferredStyle: .alert)
        let continueAction = UIAlertAction.create(title: Strings.cancelTitle,
                                                  style: .cancel,
                                                  handler: wrap(closure: `continue`))
        controller.addAction(continueAction)
        let abortAction = UIAlertAction.create(title: Strings.abortTitle, style: .destructive) { _ in
            do {
                try ApplicationServiceRegistry.walletService.abortDeployment()
            } catch let e {
                ErrorHandler.showError(log: "Failed to abort deployment", error: e)
            }
            abort()
        }
        controller.addAction(abortAction)
        return controller
    }

}
