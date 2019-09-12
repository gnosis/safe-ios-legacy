//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication


fileprivate func wrapNoArguments<T>(closure: @escaping () -> Void) -> (T) -> Void {
    return { _ in closure() }
}

extension UIAlertController {

    static func create(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = ColorName.systemBlue.color
        return alert
    }

    func withCloseAction(handler: @escaping () -> Void = {}) -> UIAlertController {
        return withDefaultAction(title: LocalizedString("close", comment: "Close"), handler: handler)
    }

    func withDefaultAction(title: String, handler: @escaping () -> Void = {}) -> UIAlertController {
        addAction(UIAlertAction(title: title,
                                style: .default,
                                handler: wrapNoArguments(closure: handler)))
        return self
    }

    func withCancelAction(handler: @escaping () -> Void = {}) -> UIAlertController {
        addAction(UIAlertAction(title: LocalizedString("cancel", comment: "Cancel"),
                                style: .cancel,
                                handler: wrapNoArguments(closure: handler)))
        return self
    }

    func withDestructiveAction(title: String, action: @escaping () -> Void) -> UIAlertController {
        addAction(UIAlertAction(title: title, style: .destructive, handler: wrapNoArguments(closure: action)))
        return self
    }

    static func networkFee() -> UIAlertController {
        return create(title: LocalizedString("transaction_fee", comment: "Network fee"),
                      message: LocalizedString("transaction_fee_explanation", comment: "Explanatory message"))
            .withCloseAction()
    }

    static func creationFee() -> UIAlertController {
        return create(title: LocalizedString("what_is_safe_creation_fee", comment: "Safe Creation Fee"),
                      message: LocalizedString("network_fee_creation", comment: "Fee explanation"))
            .withCloseAction()
    }

    static func recoveryFee() -> UIAlertController {
        return create(title: LocalizedString("what_is_safe_recovery_fee", comment: "Safe Creation Fee"),
                      message: LocalizedString("network_fee_recovery", comment: "Fee explanation"))
            .withCloseAction()
    }

    static func cancelSafeCreation(close: @escaping () -> Void, continue: @escaping () -> Void) -> UIAlertController {
        return create(title: LocalizedString("cancel_safe_creation", comment: "Title of abort safe creation alert"),
                      message: LocalizedString("cancel_creation_warning", comment: "Message body of abort alert"))
            .withCloseAction(handler: close)
            .withDestructiveAction(title: LocalizedString("continue_text", comment: "Abort safe creation button title"),
                                   action: `continue`)
    }

    static func operationFailed(message: String, close: @escaping () -> Void = {}) -> UIAlertController {
        return create(title: LocalizedString("error", comment: "Error"), message: message)
            .withCloseAction(handler: close)
    }

    static func operationFailed(reason: String, close: @escaping () -> Void = {}) -> UIAlertController {
        let template = LocalizedString("ios_creationFee_failed_error", comment: "Pending safe failed alert's message")
        return operationFailed(message: String(format: template, reason), close: close)
    }

    static func confirmReplaceSeed(handler: @escaping () -> Void) -> UIAlertController {
        let alert = create(title: LocalizedString("ios_replaceseed_confirm_title",
                                                  comment: "Confirmation alert title"),
                           message: LocalizedString("ios_replaceseed_confirm_message",
                                                    comment: "Confirmation alert message"))
        alert.addAction(UIAlertAction(title: LocalizedString("ios_replaceseed_confirm_yes",
                                                             comment: "Affirmative response button title"),
                                      style: .default,
                                      handler: wrapNoArguments(closure: handler)))
        return alert.withCancelAction()
    }

    static func disconnectWCSession(sessionName: String,
                                    withTitle: Bool,
                                    disconnectCompletion: @escaping () -> Void) -> UIAlertController {
        let message = String(format: LocalizedString("you_are_disconnecting_from",
                                                     comment: "You are disconnecting from..."),
                             sessionName)
        let alert = UIAlertController(title: nil, message: withTitle ? message : nil, preferredStyle: .actionSheet)
        let disconnectAction = UIAlertAction(title: LocalizedString("disconnect", comment: "Disconnect"),
                                             style: .destructive,
                                             handler: wrapNoArguments(closure: disconnectCompletion))
        alert.addAction(disconnectAction)
        return alert.withCancelAction()
    }

    static func failedToConnectWCUrl() -> UIAlertController {
        let alert = create(title: LocalizedString("failed_to_connect", comment: "Failed to connect."),
                           message: LocalizedString("please_try_again_later", comment: "Please try again later."))
        return alert.withCloseAction()
    }

    static func dangerousTransaction() -> UIAlertController {
        let alert = create(title: LocalizedString("transaction_blocked", comment: "Transaction blocked."),
                           message: LocalizedString("detected_dangerous_incoming_transaction",
                                                    comment: "Detected dangerous incoming transaction."))
        return alert.withCloseAction()
    }

    static func mailClientIsNotConfigured() -> UIAlertController {
        let alert = create(title: "E-mail",
                           message: ApplicationServiceRegistry.walletService.configuration.supportMail)
        return alert.withCloseAction()
    }

}
