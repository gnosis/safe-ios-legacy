//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public struct UserData {
    public var id: String
    public init(_ id: String) { self.id = id }
}

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

    let method: AuthenticationMethod
    var password: String!

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
    var status: AuthenticationStatus
    var userID: String!
    var sessionID: String!
}

// this must be responsible for registration and authentication
open class AuthenticationApplicationService {

    private let account: AccountProtocol = Account.shared

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

    @available(*, deprecated, message: "Use isAuthenticationMethodPossible(.biometry) method")
    open var isBiometricAuthenticationPossible: Bool {
        return isAuthenticationMethodPossible(.biometry)
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
        var status: AuthenticationStatus
        if user != nil {
            status = .success
        } else if isAccessPossible {
            status = .failure
        } else {
            status = .blocked
        }
        return AuthenticationResult(status: status, userID: user?.userID.id, sessionID: user?.sessionID.id)
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
        try account.cleanupAllData()
    }

}
