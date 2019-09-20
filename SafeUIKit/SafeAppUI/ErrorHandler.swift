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
        public static let fatalErrorMessage = LocalizedString("ios_fatal_description", comment: "Fatal error alert's message")
        public static let ok = LocalizedString("ok", comment: "Fatal error alert's Ok button title")

    }
    // swiftlint:enable line_length

    public static let instance = ErrorHandler()
    public var crashOnFatalError = true

    private init() {}

    public static func showFatalError(message: String = Strings.fatalErrorMessage,
                                      log: String,
                                      error: Error?,
                                      from vc: UIViewController,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
        ApplicationServiceRegistry.logger.fatal(log, error: error, file: file, line: line)
        instance.showError(title: Strings.fatalErrorTitle, message: message, log: log, error: error, from: vc) {
            if instance.crashOnFatalError {
                fatalError(message + "; " + log + (error == nil ? "" : "; \(error!): \(error!.localizedDescription)"))
            }
        }
    }

    private func showError(title: String,
                           message: String,
                           log: String,
                           error: Error?,
                           from vc: UIViewController,
                           action: @escaping () -> Void) {
        let controller = alertController(title: title, message: message, log: log, action: action)
        vc.present(controller, animated: true)
    }

    private func alertController(
        title: String, message: String, log: String, action: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.ok, style: .default) { _ in action() })
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
        case .invalidWalletState:
            return LocalizedString("ios_error_internal", comment: "Internal wallet error.")
        case .networkError:
            return LocalizedString("ios_error_generic_network", comment: "Something wrong with the network.")
        case .validationFailed:
            return LocalizedString("ios_error_generic_response", comment: "Response is invalid or not supported.")
        case .exceededExpirationDate:
            return LocalizedString("ios_error_extension_expired", comment: "Browser extension code is expired.")
        case .clientError:
            return LocalizedString("ios_error_generic_client", comment: "Application submitted invalid request.")
        case .serverError:
            return LocalizedString("ios_error_generic_server", comment: "Server returned error response.")
        case .failedToSignTransactionByDevice:
            return LocalizedString("ios_error_failed_to_sign_transaction", comment: "Failed to sign. Try again.")
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
