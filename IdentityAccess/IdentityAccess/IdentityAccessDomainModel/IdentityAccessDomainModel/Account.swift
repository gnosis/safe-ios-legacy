//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

public protocol AccountProtocol: class {

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

public enum AccountError: LoggableError {
    case settingMasterPasswordFailed
    case cleanUpAllDataFailed
}

public final class Account: AccountProtocol {

    public static let shared = Account()
    var logger: Logger {
        return DomainRegistry.logger
    }

    public var isBlocked: Bool {
        let result = passwordAttemptCount >= maxPasswordAttempts
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

    public var hasMasterPassword: Bool {
        return userDefaultsService.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false
    }

    public var isLoggedIn: Bool {
        return hasMasterPassword && session.isActive
    }

    public var isBiometryAuthenticationAvailable: Bool {
        return biometricService.isAuthenticationAvailable
    }

    public var isBiometryFaceID: Bool {
        return biometricService.biometryType == .faceID
    }

    public var isBiometryTouchID: Bool {
        return biometricService.biometryType == .touchID
    }

    public var sessionDuration: TimeInterval {
        get { return session.duration }
        set { session = Session(duration: newValue) }
    }

    public var isSessionActive: Bool {
        return session.isActive
    }

    private var userDefaultsService: KeyValueStore { return DomainRegistry.keyValueStore }
    private var keychainService: SecureStore { return DomainRegistry.secureStore }
    private var biometricService: BiometricAuthenticationService {
        return DomainRegistry.biometricAuthenticationService
    }
    private var systemClock: Clock { return DomainRegistry.clock }
    private (set) var session: Session
    public var maxPasswordAttempts: Int
    public var blockedPeriodDuration: TimeInterval

    init(sessionDuration: TimeInterval = 60 * 5,
         blockedPeriodDuration: TimeInterval = 15,
         maxPasswordAttempts: Int = 5) {
        self.session = Session(duration: sessionDuration)
        self.maxPasswordAttempts = maxPasswordAttempts
        self.blockedPeriodDuration = blockedPeriodDuration
    }

    public func setMasterPassword(_ password: String) throws {
        do {
            try keychainService.savePassword(password)
            userDefaultsService.setBool(true, for: UserDefaultsKey.masterPasswordWasSet.rawValue)
            session.start()
        } catch let e {
            throw AccountError.settingMasterPasswordFailed.nsError(causedBy: e)
        }
    }

    public func cleanupAllData() throws {
        do {
            try keychainService.removePassword()
            userDefaultsService.deleteKey(UserDefaultsKey.masterPasswordWasSet.rawValue)
            userDefaultsService.deleteKey(UserDefaultsKey.passwordAttemptCount.rawValue)
        } catch let e {
            throw AccountError.cleanUpAllDataFailed.nsError(causedBy: e)
        }
    }

    public func activateBiometricAuthentication(completion: @escaping () -> Void) {
        biometricService.activate(completion: completion)
    }

    public func authenticateWithBiometry(completion: @escaping (Bool) -> Void) {
        biometricService.authenticate { [unowned self] success in
            completion(self.authenticationResult(success))
        }
    }

    public func authenticateWithPassword(_ password: String) -> Bool {
        do {
            let isAuthenticated = authenticationResult(try keychainService.password() == password)
            passwordAttemptCount = isAuthenticated ? 0 : (passwordAttemptCount + 1)
            return isAuthenticated
        } catch let e {
            logger.error("Keychain password fetch failed", error: e, file: #file, line: #line, function: #function)
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
