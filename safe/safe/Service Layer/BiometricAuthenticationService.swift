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
        // TODO: 07/03/2018 Localize
        requestBiometry(reason: "Enable unlocking your master password with \(biometryType())") { _ in
            completion()
        }
    }

    func authenticate(completion: @escaping (Bool) -> Void) {
        // TODO: 09/03/2018 Localize
        requestBiometry(reason: "Unlock your master password with \(biometryType())", completion: completion)
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
        // TODO: 07/03/2018 Localize
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .touchID: return "Touch ID"
            case .faceID: return "Face ID"
            case .none:
                LogService.shared.error("Received unexpected biometry type: none",
                                        error: BiometricServiceError.unexpectedBiometryType)
                return "None"
            }
        } else {
            return "Touch ID"
        }
    }

}
