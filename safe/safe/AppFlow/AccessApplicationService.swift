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

class AccessApplicationService {

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
}
