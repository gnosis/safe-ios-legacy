//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import LocalAuthentication

protocol BiometricAuthenticationServiceProtocol {

    var isAuthenticationAvailable: Bool { get }
    var isBiometryFaceID: Bool { get }
    func activate(completion: @escaping () -> Void)
    func authenticate(completion: @escaping (Bool) -> Void)

}

enum BiometricServiceError: LoggableError {
    case unexpectedBiometryType
}

final class BiometricService: BiometricAuthenticationServiceProtocol {

    private let context: LAContext

    struct LocalizedString {
        static let activate = NSLocalizedString("biometry.activation.reason", "Reason to activate Touch ID or Face ID.")
        static let unlock = NSLocalizedString("biometry.authentication.reason", "Description of unlock with Touch ID.")
        static let touchID = NSLocalizedString("biometry.touchID", "Touch ID name")
        static let faceID = NSLocalizedString("biometry.faceID", "Face ID name")
        static let unrecognized = NSLocalizedString("biometry.none", "Unrecognized biometry type")
    }

    init(localAuthenticationContext: LAContext = LAContext()) {
        context = localAuthenticationContext
    }

    var isAuthenticationAvailable: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    var isBiometryFaceID: Bool {
        if #available(iOS 11.0, *) {
            // iOS specifics: pre-run policy evaluation to query biometry type
            _ = isAuthenticationAvailable
            return context.biometryType == .faceID
        } else {
            return false
        }
    }

    func activate(completion: @escaping () -> Void) {
        requestBiometry(reason: String(format: LocalizedString.activate, biometryType())) { _ in
            completion()
        }
    }

    func authenticate(completion: @escaping (Bool) -> Void) {
        requestBiometry(reason: String(format: LocalizedString.unlock, biometryType()), completion: completion)
    }

    private func requestBiometry(reason: String, completion: @escaping (Bool) -> Void) {
        if isAuthenticationAvailable {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { result, error in
                if let error = error {
                    LogService.shared.error("Failed to evaluate authentication policy", error: error)
                }
                completion(result)
            }
        } else {
            completion(false)
        }
    }

    private func biometryType() -> String {
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .touchID: return LocalizedString.touchID
            case .faceID: return LocalizedString.faceID
            case .none:
                LogService.shared.error("Received unexpected biometry type: none",
                                        error: BiometricServiceError.unexpectedBiometryType)
                return LocalizedString.unrecognized
            }
        } else {
            return LocalizedString.touchID
        }
    }

}
