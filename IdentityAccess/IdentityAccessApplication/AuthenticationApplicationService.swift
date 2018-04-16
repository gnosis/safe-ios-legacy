//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

@available(*, deprecated, message: "Will be replaced by option set")
public enum AuthenticationMethod {
    case password
    case touchID
    case faceID
}

public struct UserData {
    public var id: String
    public init(_ id: String) { self.id = id }
}

struct AuthenticationMethod1: OptionSet {
    let rawValue: Int

    static let password = AuthenticationMethod1(rawValue: 1 << 0)
    static let touchID = AuthenticationMethod1(rawValue: 1 << 1)
    static let faceID = AuthenticationMethod1(rawValue: 1 << 2)

    static let biometry: AuthenticationMethod1 = [.touchID, .faceID]
}

public struct AuthenticationRequest {

    let method: AuthenticationMethod1
    var password: String!

    private init(_ method: AuthenticationMethod1, _ password: String? = nil) {
        precondition(method == .biometry && password == nil ||
            method == .password && password != nil, "Invalid authentication request")
        self.method = method
        self.password = password
    }

    public static func biometry() -> AuthenticationRequest {
        return AuthenticationRequest(.biometry)
    }

    public static func password(_ password: String) -> AuthenticationRequest {
        return AuthenticationRequest(.password, password)
    }

}

public enum AuthenticationStatus: Hashable {
    case success
    case failure
    case blocked
}

public struct AuthenticationResult {
    var status: AuthenticationStatus
}

// this must be responsible for registration and authentication
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

    public enum Error: Swift.Error, Hashable {
        case emptyPassword
    }

    open func authenticateUser(_ request: AuthenticationRequest) throws -> AuthenticationResult {
        let user = try DomainRegistry.identityService.authenticateUser(password: request.password)
        return AuthenticationResult(status: user != nil ? .success : .failure)
    }

    @available(*, deprecated, message: "Use authenticateUser(method:) method")
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

    private var biometricService: BiometricAuthenticationService {
        return DomainRegistry.biometricAuthenticationService
    }

    @available(*, deprecated, message: "Use registerUser(password:) method")
    open func registerUser(password: String, completion: (() -> Void)?) throws {
        try registerUser(password: password)
        completion?()
    }

    open func registerUser(password: String) throws {
        _ = try DomainRegistry.identityService.registerUser(password: password)
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
