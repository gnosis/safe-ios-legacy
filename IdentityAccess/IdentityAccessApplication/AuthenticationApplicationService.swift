//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
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

    open var blockedPeriodDuration: TimeInterval {
        return account.blockedPeriodDuration
    }
    open var maxPasswordAttempts: Int {
        return account.maxPasswordAttempts
    }
    open var sessionDuration: TimeInterval {
        return account.sessionDuration
    }
    open var isUserAuthenticated: Bool {
        return account.hasMasterPassword && account.isSessionActive
    }
    open var isUserRegistered: Bool {
        return account.hasMasterPassword
    }
    open var isAuthenticationBlocked: Bool {
        return account.isBlocked
    }
    open var isBiometricAuthenticationPossible: Bool {
        return !isAuthenticationBlocked && account.isBiometryAuthenticationAvailable
    }

    open func isAuthenticationMethodSupported(_ method: AuthenticationMethod) -> Bool {
        switch method {
        case .faceID: return account.isBiometryFaceID
        case .touchID: return account.isBiometryTouchID
        case .password: return true
        }
    }

    // MARK: - Commands

    open func authenticateUser(password: String? = nil, completion: ((Bool) -> Void)? = nil) {
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

    private var userRepository: UserRepository { return DomainRegistry.userRepository }

    open func registerUser(password: String, completion: (() -> Void)? = nil) throws {
        try reset()
        let user = try User(id: userRepository.nextId(), password: password)
        try userRepository.save(user)
        try account.setMasterPassword(password)
        account.activateBiometricAuthentication {
            completion?()
        }
    }

    open func configureSession(_ duration: TimeInterval) {
        account.sessionDuration = duration
    }

    open func configureMaxPasswordAttempts(_ count: Int) {
        account.maxPasswordAttempts = count
    }

    open func configureBlockDuration(_ duration: TimeInterval) {
        account.blockedPeriodDuration = duration
    }

    open func reset() throws {
        try account.cleanupAllData()
    }

}
