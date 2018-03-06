//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol AccountProtocol: class {

    var hasMasterPassword: Bool { get }
    func cleanupAllData()
    func setMasterPassword(_ password: String) throws

}

enum AccountError: Error {
    case settingMasterPasswordFailed
}

final class Account: AccountProtocol {

    static let shared = Account(userDefaultsService: InMemoryUserDefaults(), keychainService: InMemoryKeychain())
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let keychainService: KeychainServiceProtocol

    init(userDefaultsService: UserDefaultsServiceProtocol, keychainService: KeychainServiceProtocol) {
        self.userDefaultsService = userDefaultsService
        self.keychainService = keychainService
    }

    var hasMasterPassword: Bool {
        return userDefaultsService.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false
    }

    func setMasterPassword(_ password: String) throws {
        do {
            try keychainService.savePassword(password)
            userDefaultsService.setBool(true, for: UserDefaultsKey.masterPasswordWasSet.rawValue)
        } catch {
            // TODO: 06/03/18 log keychain error
            throw AccountError.settingMasterPasswordFailed
        }
    }

    func cleanupAllData() {
        do {
            try keychainService.removePassword()
            userDefaultsService.deleteKey(UserDefaultsKey.masterPasswordWasSet.rawValue)
        } catch {
            // TODO: 06/03/18: notify user about fatal error in keychain and close the app.
        }
    }

    func checkMasterPassword(_ password: String) -> Bool {
        return false
    }

}
