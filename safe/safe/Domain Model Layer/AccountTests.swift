//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class AccountTests: XCTestCase {

    var account: Account!
    var mockUserDefaults: UserDefaultsServiceProtocol!
    var keychain: MockKeychain!

    override func setUp() {
        super.setUp()
        mockUserDefaults = InMemoryUserDefaults()
        keychain = MockKeychain()
        account = Account(userDefaultsService: mockUserDefaults, keychainService: keychain)
    }

    // TODO: 05/08/2018 implement

    // checkPassword -> Bool

    // hasBiometricAuthentication
    // authenticate(withBiometricData)
    // authenticate(withMasterPassword)
    // unlockingTime -> Time?
    // isLoggedIn - Session service
    //
    // -- unsuccessfulTries
    // -- blockedUntilDate
    // -- sessionService

    func test_hasMasterPassword_whenNoPassword_thenIsFalse() {
        XCTAssertFalse(account.hasMasterPassword)
    }

    fileprivate func setPassword() {
        XCTAssertNoThrow(try account.setMasterPassword("Password"))
    }

    func test_hasMasterPassword_whenPasswordWasSet_thenIsTrue() {
        setPassword()
        XCTAssertTrue(account.hasMasterPassword)
    }

    func test_hasMasterPassword_whenDealingWithDifferentInstances_thenResultIsTheSame() {
        setPassword()
        account = Account(userDefaultsService: mockUserDefaults, keychainService: keychain)
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

    func test_shared_exists() {
        XCTAssertNotNil(Account.shared)
    }

}

class MockKeychain: InMemoryKeychain {

    var throwsOnSavePassword = false

    enum Error: Swift.Error {
        case error
    }

    override func savePassword(_ password: String) throws {
        if throwsOnSavePassword {
            throw MockKeychain.Error.error
        }
        try super.savePassword(password)
    }
}
