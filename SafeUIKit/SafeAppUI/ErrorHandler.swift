//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import MultisigWalletApplication

public class ErrorHandler {

    // swiftlint:disable line_length
    public struct Strings {

        public static let fatalErrorTitle = LocalizedString("onboarding.fatal.title", comment: "Fatal error alert's title")
        public static let errorTitle = LocalizedString("onboarding.error.title", comment: "Error alert's title")
        public static let ok = LocalizedString("onboarding.fatal.ok", comment: "Fatal error alert's Ok button title")
        public static let fatalErrorMessage = LocalizedString("onboarding.fatal.message", comment: "Fatal error alert's message")
        public static let errorMessage = LocalizedString("generic.error.message", comment: "Generic error message alert")

    }
    // swiftlint:enable line_length

    public static let instance = ErrorHandler()
    public var chashOnFatalError = true

    private init() {}

    public static func showFatalError(message: String = Strings.fatalErrorMessage,
                                      log: String,
                                      error: Error?,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
        ApplicationServiceRegistry.logger.fatal(log, error: error, file: file, line: line)
        instance.showError(title: Strings.fatalErrorTitle, message: message, log: log, error: error) {
            if instance.chashOnFatalError {
                fatalError(message + "; " + log)
            }
        }
    }

    public static func showError(message: String = Strings.errorMessage,
                                 log: String,
                                 error: Error?,
                                 file: StaticString = #file,
                                 line: UInt = #line) {
        ApplicationServiceRegistry.logger.error(log, error: error, file: file, line: line)
        // swiftlint:disable trailing_closure
        instance.showError(title: Strings.errorTitle, message: message, log: log, error: error, action: {})
    }

    private func showError(title: String, message: String, log: String, error: Error?, action: @escaping () -> Void) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        window.rootViewController = vc
        window.windowLevel = UIWindowLevelAlert + 1
        window.makeKeyAndVisible()
        let controller = alertController(title: title, message: message, log: log, action: action)
        vc.show(controller, sender: vc)
    }

    private func alertController(
        title: String, message: String, log: String, action: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.ok, style: .destructive) { _ in action() })
        return alert
    }

    func terminate(message: String) {
        fatalError(message)
    }

}

// swiftlint:disable line_length
extension WalletApplicationService.Error: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .oneOrMoreOwnersAreMissing:
            return LocalizedString("wallet.error.owner_missing", comment: "Insufficient owners for wallet creation.")
        case .invalidWalletState:
            return LocalizedString("wallet.error.invalid_state", comment: "Internal wallet error.")
        case .missingWalletAddress:
            return LocalizedString("wallet.error.address_missing", comment: "Blockchain address is unknown for the wallet.")
        case .creationTransactionHashNotFound:
            return LocalizedString("wallet.error.creation_tx_missing", comment: "Wallet creation transaction is not found.")
        case .networkError:
            return LocalizedString("generic.error.network_error", comment: "Something wrong with network.")
        case .validationFailed:
            return LocalizedString("generic.error.response_validation_error", comment: "Response is invalid or not supported.")
        case .exceededExpirationDate:
            return LocalizedString("extension.error.expired", comment: "Browser extension code is expired.")
        case .unknownError:
            return LocalizedString("generic.error.unknown", comment: "Some error occurred.")
        }
    }

}

extension EthereumApplicationService.Error: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .invalidSignature:
            return LocalizedString("wallet.error.response_invalid_signature", comment: "Server-provided signature of creation transacion is invalid.")
        case .invalidTransaction:
            return LocalizedString("wallet.error.response_invalid_transaction", comment: "Server-provided transaction is invalid")
        case .networkError:
            return LocalizedString("generic.error.network_error", comment: "Something wrong with the network.")
        case .serverError:
            return LocalizedString("generic.error.server_error", comment: "Server returned error response.")
        case .clientError:
            return LocalizedString("generic.error.client_error", comment: "Application submitted invalid request.")
        }
    }

}
// swiftlint:enable line_length
