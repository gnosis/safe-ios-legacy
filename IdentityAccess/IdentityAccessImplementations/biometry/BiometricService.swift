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
        case .touchID: return LocalizedString("ios_touchid", comment: "Touch ID")
        case .faceID: return LocalizedString("ios_faceid", comment: "Face ID name")
        case .none: return LocalizedString("ios_none", comment: "Unrecognized biometry type")
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

    private enum Strings {
        static let activate = LocalizedString("ios_biometry_activation",
                                              comment: "Reason to activate Touch ID or Face ID.")
        static let unlock = LocalizedString("ios_biometry_reason",
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
        guard isAuthenticationAvailable else { return .none }
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .none:
            ApplicationServiceRegistry.logger.error("Received unexpected biometry type: none",
                                                    error: BiometricServiceError.unexpectedBiometryType)
            return .none
        @unknown default:
            return .none
        }
    }

    public func activate() throws {
        _ = try? requestBiometry(reason: String(format: Strings.activate, biometryType.localizedDescription))
    }

    public func authenticate() throws -> Bool {
        return try requestBiometry(reason: String(format: Strings.unlock, biometryType.localizedDescription))
    }

    @discardableResult
    private func requestBiometry(reason: String) throws -> Bool {
        guard isAuthenticationAvailable else { return false }
        var success: Bool = false
        var evaluationError: Error?
        let semaphore = DispatchSemaphore(value: 0)
        let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        context.evaluatePolicy(policy, localizedReason: reason) { result, errorOrNil in
            evaluationError = errorOrNil
            success = result
            semaphore.signal()
        }
        semaphore.wait()
        if let error = evaluationError {
            switch error {
            case LAError.authenticationFailed:
                return false
            default:
                // other error cases include cancelling biometry alert by user, by system,
                // biometry unenrolled, or failure. In this case we can't say user authentication failed - it just
                // didn't happen, so we throw that error.
                throw error
            }
        }
        return success
    }

}
