//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import MultisigWalletApplication

public class ErrorHandler {

    // swiftlint:disable line_length
    public enum Strings {

        public static let fatalErrorTitle = LocalizedString("ios_fatal", comment: "Fatal error alert's title")
        public static let errorTitle = LocalizedString("error", comment: "Error alert's title")
        public static let ok = LocalizedString("ok", comment: "Fatal error alert's Ok button title")
        public static let fatalErrorMessage = LocalizedString("ios_fatal_description", comment: "Fatal error alert's message")
        public static let errorMessage = LocalizedString("ios_error_description", comment: "Generic error message alert")

    }
    // swiftlint:enable line_length

    public static let instance = ErrorHandler()
    public var crashOnFatalError = true

    private init() {}

    public static func showFatalError(message: String = Strings.fatalErrorMessage,
                                      log: String,
                                      error: Error?,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
        ApplicationServiceRegistry.logger.fatal(log, error: error, file: file, line: line)
        instance.showError(title: Strings.fatalErrorTitle, message: message, log: log, error: error) {
            if instance.crashOnFatalError {
                fatalError(message + "; " + log + (error == nil ? "" : "; \(error!): \(error!.localizedDescription)"))
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
        window.windowLevel = UIWindow.Level.alert + 1
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
extension WalletApplicationServiceError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .oneOrMoreOwnersAreMissing:
            return LocalizedString("ios_error_owner_missing", comment: "Insufficient owners for wallet creation.")
        case .invalidWalletState:
            return LocalizedString("ios_error_internal", comment: "Internal wallet error.")
        case .missingWalletAddress:
            return LocalizedString("ios_error_address_missing", comment: "Blockchain address is unknown for the wallet.")
        case .creationTransactionHashNotFound:
            return LocalizedString("ios_error_creation_tx_missing", comment: "Wallet creation transaction is not found.")
        case .networkError:
            return LocalizedString("ios_error_generic_network", comment: "Something wrong with the network.")
        case .validationFailed:
            return LocalizedString("ios_error_generic_response", comment: "Response is invalid or not supported.")
        case .exceededExpirationDate:
            return LocalizedString("ios_error_extension_expired", comment: "Browser extension code is expired.")
        case .unknownError:
            return LocalizedString("ios_error_generic_unknown", comment: "Some error occurred.")
        case .clientError:
            return LocalizedString("ios_error_generic_client", comment: "Application submitted invalid request.")
        case .serverError:
            return LocalizedString("ios_error_generic_server", comment: "Server returned error response.")
        case .walletCreationFailed:
            return LocalizedString("ios_error_deployment_failed", comment: "Failed to deploy new safe. All funds are lost.")
        }
    }

}

extension EthereumApplicationService.Error: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .invalidSignature:
            return LocalizedString("ios_error_invalid_signature", comment: "Server-provided signature of creation transacion is invalid.")
        case .invalidTransaction:
            return LocalizedString("ios_error_invalid_transaction", comment: "Server-provided transaction is invalid")
        case .networkError:
            return WalletApplicationServiceError.networkError.errorDescription
        case .serverError:
            return WalletApplicationServiceError.serverError.errorDescription
        case .clientError:
            return WalletApplicationServiceError.clientError.errorDescription
        }
    }

}
// swiftlint:enable line_length
