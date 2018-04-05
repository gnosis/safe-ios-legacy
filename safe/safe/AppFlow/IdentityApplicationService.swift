//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

enum AuthenticationMethod {
    case password
    case touchID
    case faceID
}

struct AuthenticateUserCommand {

    var password: String!
    var isBiometric: Bool { return password == nil }
    typealias AuthenticationCompletion = (Bool) -> Void
    var completion: AuthenticationCompletion

    private init(password: String?, completion: @escaping AuthenticationCompletion) {
        self.password = password
        self.completion = completion
    }

    static func withPassword(_ password: String,
                             completion: @escaping AuthenticationCompletion) -> AuthenticateUserCommand {
        return AuthenticateUserCommand(password: password, completion: completion)
    }

    static func withBiometry(completion: @escaping AuthenticationCompletion) -> AuthenticateUserCommand {
        return AuthenticateUserCommand(password: nil, completion: completion)
    }
}

struct RegisterUserCommand {

    var password: String
    var completion: RegisterCompletion
    typealias RegisterCompletion = () -> Void

    init(_ password: String, completion: @escaping RegisterCompletion) {
        self.password = password
        self.completion = completion
    }
}

class IdentityApplicationService {

    let account: AccountProtocol

    var blockedPeriodDuration: TimeInterval { return account.blockedPeriodDuration }

    init(account: AccountProtocol) {
        self.account = account
    }

    func hasAccess() -> Bool {
        return account.hasMasterPassword && !account.isSessionActive
    }

    func hasPrimaryUser() -> Bool {
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

    func authenticateUser(_ command: AuthenticateUserCommand) {
        if isBlocked() {
            command.completion(false)
            return
        }
        if command.isBiometric {
            account.authenticateWithBiometry(completion: command.completion)
        } else {
            command.completion(account.authenticateWithPassword(command.password))
        }
    }

    func registerUser(_ command: RegisterUserCommand) throws {
        try account.cleanupAllData()
        try account.setMasterPassword(command.password)
        account.activateBiometricAuthentication(completion: command.completion)
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
