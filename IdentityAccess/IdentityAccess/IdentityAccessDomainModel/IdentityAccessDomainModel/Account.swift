//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol AccountProtocol: class {

    var hasMasterPassword: Bool { get }
    var isLoggedIn: Bool { get }
    var isBiometryAuthenticationAvailable: Bool { get }
    var isBiometryFaceID: Bool { get }
    var isBiometryTouchID: Bool { get }
    var isBlocked: Bool { get }
    var blockedPeriodDuration: TimeInterval { get set }
    var sessionDuration: TimeInterval { get set }
    var maxPasswordAttempts: Int { get set }
    var isSessionActive: Bool { get }

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
        let result = passwordAttemptCount >= maxPasswordAttempts
        LogService.shared.debug("Blocked? \(result ? "YES" : "NO")")
        return result
    }

    private var passwordAttemptCount: Int {
        get {
            return self.userDefaultsService.int(for: UserDefaultsKey.passwordAttemptCount.rawValue) ?? 0
        }
        set {
            self.userDefaultsService.setInt(newValue, for: UserDefaultsKey.passwordAttemptCount.rawValue)
        }
    }

    var hasMasterPassword: Bool {
        return userDefaultsService.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false
    }

    var isLoggedIn: Bool {
        return hasMasterPassword && session.isActive
    }

    var isBiometryAuthenticationAvailable: Bool {
        return biometricService.isAuthenticationAvailable
    }

    var isBiometryFaceID: Bool {
        return biometricService.biometryType == .faceID
    }

    var isBiometryTouchID: Bool {
        return biometricService.biometryType == .touchID
    }

    var sessionDuration: TimeInterval {
        get { return session.duration }
        set { session = Session(duration: newValue) }
    }

    var isSessionActive: Bool {
        return session.isActive
    }

    private var userDefaultsService: KeyValueStore { return DomainRegistry.keyValueStore }
    private var keychainService: SecureStore { return DomainRegistry.secureStore }
    private var biometricService: BiometricAuthenticationService {
        return DomainRegistry.biometricAuthenticationService
    }
    private var systemClock: Clock { return DomainRegistry.clock }
    private (set) var session: Session
    var maxPasswordAttempts: Int
    var blockedPeriodDuration: TimeInterval

    init(sessionDuration: TimeInterval = 60 * 5,
         blockedPeriodDuration: TimeInterval = 15,
         maxPasswordAttempts: Int = 5) {
        self.session = Session(duration: sessionDuration)
        self.maxPasswordAttempts = maxPasswordAttempts
        self.blockedPeriodDuration = blockedPeriodDuration
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
            userDefaultsService.deleteKey(UserDefaultsKey.passwordAttemptCount.rawValue)
        } catch let e {
            throw AccountError.cleanUpAllDataFailed.nsError(causedBy: e)
        }
    }

    func activateBiometricAuthentication(completion: @escaping () -> Void) {
        biometricService.activate(completion: completion)
    }

    func authenticateWithBiometry(completion: @escaping (Bool) -> Void) {
        biometricService.authenticate { [unowned self] success in
            completion(self.authenticationResult(success))
        }
    }

    func authenticateWithPassword(_ password: String) -> Bool {
        do {
            let isAuthenticated = authenticationResult(try keychainService.password() == password)
            passwordAttemptCount = isAuthenticated ? 0 : (passwordAttemptCount + 1)
            return isAuthenticated
        } catch let e {
            LogService.shared.error("Keychain password fetch failed", error: e)
            return false
        }
    }

    private func authenticationResult(_ success: Bool) -> Bool {
        if success {
            session.start()
        }
        return success
    }

}
