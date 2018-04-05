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

    let account: AccountProtocol

    var blockedPeriodDuration: TimeInterval { return account.blockedPeriodDuration }

    init(account: AccountProtocol) {
        self.account = account
    }

    func hasAccess() -> Bool {
        return account.hasMasterPassword && !account.isSessionActive
    }

    func hasRegisteredUser() -> Bool {
        return account.hasMasterPassword
    }

    func hasAuthenticationMethod(_ method: AuthenticationMethod) -> Bool {
        switch method {
        case .faceID: return account.isBiometryFaceID
        case .touchID: return account.isBiometryTouchID
        case .password: return true
        }
    }

    func isBlocked() -> Bool {
        return account.isBlocked
    }

    func isBiometricAuthenticationPossible() -> Bool {
        return !isBlocked() && account.isBiometryAuthenticationAvailable
    }

    func authenticateUser(password: String? = nil, completion: @escaping (Bool) -> Void) {
        if isBlocked() {
            completion(false)
            return
        }
        if let password = password {
            completion(account.authenticateWithPassword(password))
        } else {
            account.authenticateWithBiometry(completion: completion)
        }
    }

    func registerUser(password: String, completion: (() -> Void)? = nil) throws {
        try account.cleanupAllData()
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

}
