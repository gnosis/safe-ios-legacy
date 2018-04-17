//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel


public struct AuthenticationMethod: OptionSet {

    public let rawValue: Int

    public static let password = AuthenticationMethod(rawValue: 1 << 0)
    public static let touchID = AuthenticationMethod(rawValue: 1 << 1)
    public static let faceID = AuthenticationMethod(rawValue: 1 << 2)

    public static let biometry: AuthenticationMethod = [.touchID, .faceID]

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct AuthenticationRequest {

    public let method: AuthenticationMethod
    public let password: String!

    private init(_ method: AuthenticationMethod, _ password: String? = nil) {
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
    public let status: AuthenticationStatus
    public let userID: String!
    public let sessionID: String!

    public static let blocked = AuthenticationResult(status: .blocked, userID: nil, sessionID: nil)
    public static let failure = AuthenticationResult(status: .failure, userID: nil, sessionID: nil)
    public static func success(userID: String, sessionID: String) -> AuthenticationResult {
        return AuthenticationResult(status: .success, userID: userID, sessionID: sessionID)
    }
}

// this must be responsible for registration and authentication
open class AuthenticationApplicationService {

    public init() {}

    // MARK: - Queries

    open var blockedPeriodDuration: TimeInterval {
        return gatekeeper.policy.blockDuration
    }
    open var maxPasswordAttempts: Int {
        return gatekeeper.policy.maxFailedAttempts
    }
    open var sessionDuration: TimeInterval {
        return gatekeeper.policy.sessionDuration
    }
    open func isUserAuthenticated(session: String) -> Bool {
        guard let id = try? SessionID(session) else { return false }
        return gatekeeper.hasAccess(session: id, at: clock.currentTime)
    }
    open var isUserRegistered: Bool {
        return userRepository.primaryUser() != nil
    }
    open var isAuthenticationBlocked: Bool {
        return !gatekeeper.isAccessPossible(at: clock.currentTime)
    }

    open func isAuthenticationMethodSupported(_ method: AuthenticationMethod) -> Bool {
        var supported: AuthenticationMethod = .password
        if biometricService.biometryType == .touchID {
            supported.insert(.touchID)
        }
        if biometricService.biometryType == .faceID {
            supported.insert(.faceID)
        }
        return !method.isDisjoint(with: supported)
    }

    open func isAuthenticationMethodPossible(_ method: AuthenticationMethod) -> Bool {
        guard isAccessPossible else { return false }
        var possible: AuthenticationMethod = .password
        if isAuthenticationMethodSupported(.faceID) && biometricService.isAuthenticationAvailable {
            possible.insert(.faceID)
        }
        if isAuthenticationMethodSupported(.touchID) && biometricService.isAuthenticationAvailable {
            possible.insert(.touchID)
        }
        return !method.isDisjoint(with: possible)
    }

    // MARK: - Commands

    public enum Error: Swift.Error, Hashable {
        case emptyPassword
    }

    private var gatekeeperRepository: GatekeeperRepository { return DomainRegistry.gatekeeperRepository }
    private var gatekeeper: Gatekeeper! { return gatekeeperRepository.gatekeeper() }
    private var clock: Clock { return DomainRegistry.clock }
    private var identityService: IdentityService { return DomainRegistry.identityService }

    private var isAccessPossible: Bool {
        return gatekeeper.isAccessPossible(at: clock.currentTime)
    }

    open func authenticateUser(_ request: AuthenticationRequest) throws -> AuthenticationResult {
        let user: UserDescriptor?
        if request.method == .password {
            user = try identityService.authenticateUser(password: request.password)
        } else if request.method.isSubset(of: .biometry) {
            user = try identityService.authenticateUserBiometrically()
        } else {
            preconditionFailure("Invalid authentication method in request \(request)")
        }
        if let user = user {
            return .success(userID: user.userID.id, sessionID: user.sessionID.id)
        } else if isAccessPossible {
            return .failure
        } else {
            return .blocked
        }
    }

    private var userRepository: UserRepository { return DomainRegistry.userRepository }

    private var biometricService: BiometricAuthenticationService {
        return DomainRegistry.biometricAuthenticationService
    }

    open func registerUser(password: String) throws {
        _ = try DomainRegistry.identityService.registerUser(password: password)
    }

    open func configureSession(_ duration: TimeInterval) throws {
        try gatekeeper.changeSessionDuration(duration)
        try gatekeeperRepository.save(gatekeeper)
    }

    open func configureMaxPasswordAttempts(_ count: Int) throws {
        try gatekeeper.changeMaxFailedAttempts(count)
        try gatekeeperRepository.save(gatekeeper)
    }

    open func configureBlockDuration(_ duration: TimeInterval) throws {
        try gatekeeper.changeBlockDuration(duration)
        try gatekeeperRepository.save(gatekeeper)
    }

    open func reset() throws {
        if let user = userRepository.primaryUser() {
            try userRepository.remove(user)
        }
        if let gatekeeper = gatekeeper {
            gatekeeper.reset()
            try DomainRegistry.gatekeeperRepository.save(gatekeeper)
        }
    }

}
