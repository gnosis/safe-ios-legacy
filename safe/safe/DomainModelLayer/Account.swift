//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol AccountProtocol: class {

    var hasMasterPassword: Bool { get }
    var isLoggedIn: Bool { get }
    var isBiometryAuthenticationAvailable: Bool { get }
    var isBiometryFaceID: Bool { get }
    var isBlocked: Bool { get }

    func cleanupAllData() throws
    func setMasterPassword(_ password: String) throws
    func activateBiometricAuthentication(completion: @escaping () -> Void)
    func authenticateWithBiometry(completion: @escaping (Bool) -> Void)
    func authenticateWithPassword(_ password: String) -> Bool

}

enum AccountError: LoggableError {
    case settingMasterPasswordFailed
    case cleanUpAllDataFailed
}

final class Account: AccountProtocol {

    static let shared = Account()

    var isBlocked: Bool {
        return passwordAttemptCount >= maxPasswordAttempts
    }

    private var passwordAttemptCount: Int {
        get { return self.userDefaultsService.int(for: UserDefaultsKey.passwordAttemptCount.rawValue) ?? 0 }
        set { self.userDefaultsService.setInt(newValue, for: UserDefaultsKey.passwordAttemptCount.rawValue) }
    }

    var hasMasterPassword: Bool {
        return userDefaultsService.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false
    }

    var isLoggedIn: Bool {
        return hasMasterPassword && session.isActive
    }

    var isBiometryAuthenticationAvailable: Bool {
        return biometricAuthService.isAuthenticationAvailable
    }

    var isBiometryFaceID: Bool {
        return biometricAuthService.biometryType == .faceID
    }

    private let userDefaultsService: UserDefaultsServiceProtocol
    private let keychainService: KeychainServiceProtocol
    private let biometricAuthService: BiometricAuthenticationServiceProtocol
    private var session: Session
    private let maxPasswordAttempts: Int

    init(userDefaultsService: UserDefaultsServiceProtocol = UserDefaultsService(),
         keychainService: KeychainServiceProtocol = KeychainService(),
         biometricAuthService: BiometricAuthenticationServiceProtocol = BiometricService(),
         systemClock: SystemClockServiceProtocol = SystemClockService(),
         sessionDuration: TimeInterval = 60 * 5,
         maxPasswordAttempts: Int = 5) {
        self.userDefaultsService = userDefaultsService
        self.keychainService = keychainService
        self.biometricAuthService = biometricAuthService
        self.session = Session(duration: sessionDuration, clockService: systemClock)
        self.maxPasswordAttempts = maxPasswordAttempts
    }

    func setMasterPassword(_ password: String) throws {
        do {
            try keychainService.savePassword(password)
            userDefaultsService.setBool(true, for: UserDefaultsKey.masterPasswordWasSet.rawValue)
            session.start()
        } catch let e {
            throw AccountError.settingMasterPasswordFailed.nsError(causedBy: e)
        }
    }

    func cleanupAllData() throws {
        do {
            try keychainService.removePassword()
            userDefaultsService.deleteKey(UserDefaultsKey.masterPasswordWasSet.rawValue)
        } catch let e {
            throw AccountError.cleanUpAllDataFailed.nsError(causedBy: e)
        }
    }

    func activateBiometricAuthentication(completion: @escaping () -> Void) {
        biometricAuthService.activate(completion: completion)
    }

    func authenticateWithBiometry(completion: @escaping (Bool) -> Void) {
        biometricAuthService.authenticate { [unowned self] success in
            completion(self.authenticationResult(success))
        }
    }

    func authenticateWithPassword(_ password: String) -> Bool {
        do {
            return authenticationResult(try keychainService.password() == password)
        } catch let e {
            LogService.shared.error("Keychain password fetch failed", error: e)
            return false
        }
    }

    private func authenticationResult(_ success: Bool) -> Bool {
        if success {
            passwordAttemptCount = 0
            session.start()
        } else {
            passwordAttemptCount += 1
        }
        return success
    }

}
