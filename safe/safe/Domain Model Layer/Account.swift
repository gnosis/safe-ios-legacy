//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol AccountProtocol: class {

    var hasMasterPassword: Bool { get }
    var isLoggedIn: Bool { get }
    var isBiometryAuthenticationAvailable: Bool { get }

    func cleanupAllData()
    func setMasterPassword(_ password: String) throws
    func activateBiometricAuthentication(completion: @escaping () -> Void)
    func authenticateWithBiometry(completion: @escaping (Bool) -> Void)
    func authenticateWithPassword(_ password: String) -> Bool

}

enum AccountError: Error {
    case settingMasterPasswordFailed
}

final class Account: AccountProtocol {

    static let shared = Account()
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let keychainService: KeychainServiceProtocol
    private let biometricAuthService: BiometricAuthenticationServiceProtocol
    private var session: Session

    init(userDefaultsService: UserDefaultsServiceProtocol = UserDefaultsService(),
         keychainService: KeychainServiceProtocol = KeychainService(),
         biometricAuthService: BiometricAuthenticationServiceProtocol = BiometricService(),
         systemClock: SystemClockServiceProtocol = SystemClockService(),
         sessionDuration: TimeInterval = 60 * 5) {
        self.userDefaultsService = userDefaultsService
        self.keychainService = keychainService
        self.biometricAuthService = biometricAuthService
        self.session = Session(duration: sessionDuration, clockService: systemClock)
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

    func setMasterPassword(_ password: String) throws {
        do {
            try keychainService.savePassword(password)
            userDefaultsService.setBool(true, for: UserDefaultsKey.masterPasswordWasSet.rawValue)
            session.start()
        } catch let e {
            // TODO: 06/03/18 log keychain error
            print("Failed to set master password: \(e)")
            throw AccountError.settingMasterPasswordFailed
        }
    }

    func cleanupAllData() {
        do {
            try keychainService.removePassword()
            userDefaultsService.deleteKey(UserDefaultsKey.masterPasswordWasSet.rawValue)
        } catch let e {
            // TODO: 06/03/18: notify user about fatal error in keychain and close the app.
            print("Failed to cleanup all data: \(e)")
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
            // TODO: 09/03/18: log error
            print("Password fetch failed: \(e)")
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
