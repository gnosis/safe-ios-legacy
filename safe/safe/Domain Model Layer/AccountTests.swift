//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class AccountTests: XCTestCase {

    var account: Account!
    let mockUserDefaults = InMemoryUserDefaults()
    let keychain = MockKeychain()
    let biometricService = MockBiometricService()

    override func setUp() {
        super.setUp()
        account = Account(userDefaultsService: mockUserDefaults,
                          keychainService: keychain,
                          biometricAuthService: biometricService)
    }

    func test_hasMasterPassword_whenNoPassword_thenIsFalse() {
        XCTAssertFalse(account.hasMasterPassword)
    }

    fileprivate func setPassword() {
        XCTAssertNoThrow(try account.setMasterPassword("Password"))
    }

    func test_shared_exists() {
        XCTAssertNotNil(Account.shared)
    }

    func test_hasMasterPassword_whenPasswordWasSet_thenIsTrue() {
        setPassword()
        XCTAssertTrue(account.hasMasterPassword)
    }

    func test_hasMasterPassword_whenDealingWithDifferentInstances_thenResultIsTheSame() {
        setPassword()
        account = Account(userDefaultsService: mockUserDefaults,
                          keychainService: keychain,
                          biometricAuthService: biometricService)
        XCTAssertTrue(account.hasMasterPassword)
    }

    func test_setMasterPassword_whenWasSet_thenUserDefaultsPropertyIsSet() {
        setPassword()
        XCTAssertTrue(mockUserDefaults.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false)
    }

    func test_setMasterPassword_whenWasSet_thenStoresPasswordInKeychain() {
        setPassword()
        XCTAssertEqual(try! keychain.password(), "Password")
    }

    func test_setMasterPassword_whenKeychainThrows_thenSettingPasswordThrows() {
        keychain.throwsOnSavePassword = true
        XCTAssertThrowsError(try account.setMasterPassword("Password"), "Expected Account Error") { error in
            XCTAssertEqual(error.localizedDescription, AccountError.settingMasterPasswordFailed.localizedDescription)
        }
    }

    func test_cleanupAllData_whenCalled_thenAccountDataIsCleaned() {
        setPassword()
        account.cleanupAllData()
        XCTAssertFalse(account.hasMasterPassword)
        XCTAssertFalse(mockUserDefaults.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false)
        XCTAssertNil(try! keychain.password())
    }

    func test_checkMasterPassword_whenNoPasswordWasSet_thenReturnsFalse() {
        XCTAssertFalse(account.checkMasterPassword("Password"))
    }

    func test_checkMasterPassword_whenPasswordIsWrong_thenReturnsFalse() {
        setPassword()
        XCTAssertFalse(account.checkMasterPassword("WrongPassword"))
    }

    func test_activateBiometricAuthentication_whenInvoked_thenCallsAccountCompletionAfterBiometricActivation() {
        var completionCalled = false
        biometricService.shouldActivateImmediately = false
        account.activateBiometricAuthentication {
            completionCalled = true
        }
        wait()
        XCTAssertFalse(completionCalled)
        biometricService.completeActivation()
        XCTAssertTrue(completionCalled)
    }

    func test_isLoggedIn_whenPasswordIsSet_thenIsTrue() {
        XCTAssertFalse(account.isLoggedIn)
        setPassword()
        XCTAssertTrue(account.isLoggedIn)
    }

}

class InMemoryUserDefaults: UserDefaultsServiceProtocol {

    var dict = [String: Bool]()

    func bool(for key: String) -> Bool? {
        return dict[key]
    }

    func setBool(_ value: Bool, for key: String) {
        dict[key] = value
    }

    func deleteKey(_ key: String) {
        dict.removeValue(forKey: key)
    }

}

class MockKeychain: KeychainServiceProtocol {

    private var storedPassword: String?
    var throwsOnSavePassword = false

    enum Error: Swift.Error {
        case error
    }

    func password() throws -> String? {
        return storedPassword
    }

    func savePassword(_ password: String) throws {
        if throwsOnSavePassword {
            throw MockKeychain.Error.error
        }
        storedPassword = password
    }

    func removePassword() throws {
        storedPassword = nil
    }

}

class MockBiometricService: BiometricAuthenticationServiceProtocol {

    var savedCompletion: (() -> Void)?
    var shouldActivateImmediately = false

    func activate(completion: @escaping () -> Void) {
        if shouldActivateImmediately {
            completion()
        } else {
            savedCompletion = completion
        }
    }

    func completeActivation() {
        savedCompletion?()
    }

}
