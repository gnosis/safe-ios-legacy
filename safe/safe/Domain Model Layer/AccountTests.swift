//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class AccountTests: XCTestCase {

    var account: Account!
    var mockUserDefaults: UserDefaultsService!

    override func setUp() {
        super.setUp()
        mockUserDefaults = InMemoryUserDefaults()
        account = Account(userDefaultsService: mockUserDefaults)
        account.cleanupAllData()
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

    func test_hasMasterPassword_whenPasswordWasSet_thenIsTrue() {
        account.setMasterPassword("Password")
        XCTAssertTrue(account.hasMasterPassword)
    }

    func test_hasMasterPassword_whenDealingWithDifferentInstances_thenResultIsTheSame() {
        account.setMasterPassword("Password")
        account = Account(userDefaultsService: mockUserDefaults)
        XCTAssertTrue(account.hasMasterPassword)
    }

    func test_setMasterPassword_whenWasSet_thenUserDefaultsPropertyIsSet() {
        account.setMasterPassword("Password")
        XCTAssertTrue(mockUserDefaults.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false)
    }

    func test_cleanupAllData_whenCalled_thenAccountDataIsCleaned() {
        account.setMasterPassword("Password")
        account.cleanupAllData()
        XCTAssertFalse(account.hasMasterPassword)
        XCTAssertFalse(mockUserDefaults.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false)
    }

    func test_checkMasterPassword_whenNoPasswordWasSet_thenReturnsFalse() {
        XCTAssertFalse(account.checkMasterPassword("Password"))
    }

    func test_checkMasterPassword_whenPasswordIsWrong_thenReturnsFalse() {
        account.setMasterPassword("Password")
        XCTAssertFalse(account.checkMasterPassword("WrongPassword"))
    }

    func test_shared_exists() {
        XCTAssertNotNil(Account.shared)
    }

}
