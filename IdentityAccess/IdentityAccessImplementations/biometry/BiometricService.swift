//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import LocalAuthentication
import IdentityAccessDomainModel

extension BiometryType {

    var localizedDescription: String {
        switch self {
        case .touchID: return NSLocalizedString("biometry.touchID", comment: "Touch ID")
        case .faceID: return NSLocalizedString("biometry.faceID", comment: "Face ID name")
        case .none: return NSLocalizedString("biometry.none", comment: "Unrecognized biometry type")
        }
    }

}

public enum BiometricServiceError: LoggableError {
    case unexpectedBiometryType
}

public final class BiometricService: BiometricAuthenticationService {

    private let context: LAContext

    private struct LocalizedString {
        static let activate = NSLocalizedString("biometry.activation.reason",
                                                comment: "Reason to activate Touch ID or Face ID.")
        static let unlock = NSLocalizedString("biometry.authentication.reason",
                                              comment: "Description of unlock with Touch ID.")
    }

    public init(localAuthenticationContext: LAContext = LAContext()) {
        context = localAuthenticationContext
    }

    public var isAuthenticationAvailable: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    public var biometryType: BiometryType {
       if #available(iOS 11.0, *) {
            guard isAuthenticationAvailable else { return .none }
            // biometryType available from iOS 11.0
            switch context.biometryType {
            case .faceID: return .faceID
            case .touchID: return .touchID
            case .none:
                LogService.shared.error("Received unexpected biometry type: none",
                                        error: BiometricServiceError.unexpectedBiometryType)
                return .none
            }
       } else {
            return isAuthenticationAvailable ? .touchID : .none
        }
    }

    public func activate(completion: @escaping () -> Void) {
        requestBiometry(reason: String(format: LocalizedString.activate, biometryType.localizedDescription)) { _ in
            completion()
        }
    }

    public func activate() throws {
        self.activate { }
    }

    public func authenticate(completion: @escaping (Bool) -> Void) {
        requestBiometry(reason: String(format: LocalizedString.unlock, biometryType.localizedDescription),
                        completion: completion)
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

}
