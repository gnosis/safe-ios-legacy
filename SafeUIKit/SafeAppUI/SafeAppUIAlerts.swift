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

    private enum Strings {

        static let title = LocalizedString("cancel_safe_creation", comment: "Title of abort safe creation alert")
        static let message = LocalizedString("cancel_creation_warning", comment: "Message body of abort alert")
        static let abortTitle = LocalizedString("continue_text", comment: "Abort safe creation button title")
        static let cancelTitle = LocalizedString("close", comment: "Button to cancel 'abort create' alert")

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
            ApplicationServiceRegistry.walletService.abortDeployment()
            abort()
        }
        controller.addAction(abortAction)
        return controller
    }

}

class TransactionFeeAlertController: SafeAlertController {

    static func create() -> TransactionFeeAlertController {
        let alert = TransactionFeeAlertController(title: LocalizedString("transaction_fee", comment: "Network fee"),
                                                  message: LocalizedString("transaction_fee_explanation",
                                                                           comment: "Explanatory message"),
                                                  preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString("close", comment: "Close"), style: .default))
        return alert
    }

}
