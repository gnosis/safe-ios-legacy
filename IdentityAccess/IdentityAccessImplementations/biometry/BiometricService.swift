//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import LocalAuthentication
import IdentityAccessDomainModel
import IdentityAccessApplication

extension BiometryType {

    var localizedDescription: String {
        switch self {
        case .touchID: return LocalizedString("biometry.touchID", comment: "Touch ID")
        case .faceID: return LocalizedString("biometry.faceID", comment: "Face ID name")
        case .none: return LocalizedString("biometry.none", comment: "Unrecognized biometry type")
        }
    }

}

/// Biometric error
///
/// - unexpectedBiometryType: encountered unrecognized biometry type.
public enum BiometricServiceError: LoggableError {
    case unexpectedBiometryType
}

public final class BiometricService: BiometricAuthenticationService {

    private let contextProvider: () -> LAContext
    private var context: LAContext

    private struct Strings {
        static let activate = LocalizedString("biometry.activation.reason",
                                              comment: "Reason to activate Touch ID or Face ID.")
        static let unlock = LocalizedString("biometry.authentication.reason",
                                            comment: "Description of unlock with Touch ID.")
    }

    /// Creates new biometric service with LAContext provider.
    ///
    /// Autoclosure here means that LAContext will be fetched every time from the closure.
    /// By default, it will be created anew when contextProvider() is called.
    /// We have to re-create LAContext so that previous biometry authentication is not reused by the system.
    ///
    /// - Parameter localAuthenticationContext: closure that returns LAContext.
    public init(localAuthenticationContext: @escaping @autoclosure () -> LAContext = LAContext()) {
        self.contextProvider = localAuthenticationContext
        context = contextProvider()
    }

    public var isAuthenticationAvailable: Bool {
        context = contextProvider()
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
                ApplicationServiceRegistry.logger.error("Received unexpected biometry type: none",
                                                        error: BiometricServiceError.unexpectedBiometryType)
                return .none
            }
        } else {
            return isAuthenticationAvailable ? .touchID : .none
        }
    }

    public func activate() throws {
        requestBiometry(reason: String(format: Strings.activate, biometryType.localizedDescription))
    }

    public func authenticate() -> Bool {
        return requestBiometry(reason: String(format: Strings.unlock, biometryType.localizedDescription))
    }

    @discardableResult
    private func requestBiometry(reason: String) -> Bool {
        guard isAuthenticationAvailable else { return false }
        var success: Bool = false
        let semaphore = DispatchSemaphore(value: 0)
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { result, error in
            if let error = error {
                ApplicationServiceRegistry.logger.error("Failed to evaluate authentication policy", error: error)
            }
            success = result
            semaphore.signal()
        }
        semaphore.wait()
        return success
    }

}
