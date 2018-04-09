//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public enum AuthenticationMethod {
    case password
    case touchID
    case faceID
}

open class AuthenticationApplicationService {

    private let account: AccountProtocol = Account.shared

    public init() {}

    // MARK: - Queries

    public var blockedPeriodDuration: TimeInterval {
        return account.blockedPeriodDuration
    }
    public var maxPasswordAttempts: Int {
        return account.maxPasswordAttempts
    }
    public var sessionDuration: TimeInterval {
        return account.sessionDuration
    }
    public var isUserAuthenticated: Bool {
        return account.hasMasterPassword && !account.isSessionActive
    }
    public var isUserRegistered: Bool {
        return account.hasMasterPassword
    }
    public var isAuthenticationBlocked: Bool {
        return account.isBlocked
    }
    public var isBiometricAuthenticationPossible: Bool {
        return !isAuthenticationBlocked && account.isBiometryAuthenticationAvailable
    }

    public func isAuthenticationMethodSupported(_ method: AuthenticationMethod) -> Bool {
        switch method {
        case .faceID: return account.isBiometryFaceID
        case .touchID: return account.isBiometryTouchID
        case .password: return true
        }
    }

    // MARK: - Commands

    public func authenticateUser(password: String? = nil, completion: ((Bool) -> Void)? = nil) {
        if isAuthenticationBlocked {
            completion?(false)
            return
        }
        if let password = password {
            completion?(account.authenticateWithPassword(password))
        } else {
            account.authenticateWithBiometry { completion?($0) }
        }
    }

    public func registerUser(password: String, completion: (() -> Void)? = nil) throws {
        try reset()
        try account.setMasterPassword(password)
        account.activateBiometricAuthentication {
            completion?()
        }
    }

    public func configureSession(_ duration: TimeInterval) {
        account.sessionDuration = duration
    }

    public func configureMaxPasswordAttempts(_ count: Int) {
        account.maxPasswordAttempts = count
    }

    public func configureBlockDuration(_ duration: TimeInterval) {
        account.blockedPeriodDuration = duration
    }

    public func reset() throws {
        try account.cleanupAllData()
    }

}
