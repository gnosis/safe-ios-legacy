//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

enum AuthenticationMethod {
    case password
    case touchID
    case faceID
}

class AuthenticationApplicationService {

    private let account: AccountProtocol = Account.shared

    var blockedPeriodDuration: TimeInterval {
        return account.blockedPeriodDuration
    }
    var maxPasswordAttempts: Int {
        return account.maxPasswordAttempts
    }
    var sessionDuration: TimeInterval {
        return account.sessionDuration
    }

    func isUserAuthenticated() -> Bool {
        return account.hasMasterPassword && !account.isSessionActive
    }

    func isUserRegistered() -> Bool {
        return account.hasMasterPassword
    }

    func isAuthenticationMethodSupported(_ method: AuthenticationMethod) -> Bool {
        switch method {
        case .faceID: return account.isBiometryFaceID
        case .touchID: return account.isBiometryTouchID
        case .password: return true
        }
    }

    func isAuthenticationBlocked() -> Bool {
        return account.isBlocked
    }

    func isBiometricAuthenticationPossible() -> Bool {
        return !isAuthenticationBlocked() && account.isBiometryAuthenticationAvailable
    }

    func authenticateUser(password: String? = nil, completion: ((Bool) -> Void)? = nil) {
        if isAuthenticationBlocked() {
            completion?(false)
            return
        }
        if let password = password {
            completion?(account.authenticateWithPassword(password))
        } else {
            account.authenticateWithBiometry { completion?($0) }
        }
    }

    func registerUser(password: String, completion: (() -> Void)? = nil) throws {
        try reset()
        try account.setMasterPassword(password)
        account.activateBiometricAuthentication {
            completion?()
        }
    }

    func configureSession(_ duration: TimeInterval) {
        account.sessionDuration = duration
    }

    func configureMaxPasswordAttempts(_ count: Int) {
        account.maxPasswordAttempts = count
    }

    func configureBlockDuration(_ duration: TimeInterval) {
        account.blockedPeriodDuration = duration
    }

    func reset() throws {
        try account.cleanupAllData()
    }

}
