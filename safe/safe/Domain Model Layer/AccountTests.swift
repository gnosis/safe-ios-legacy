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
        mockUserDefaults = MockUserDefaults()
        account = Account(userDefaultsService: mockUserDefaults)
    }

    // TODO: 05/08/2018 implement

    // hasMasterPassword
    // setMasterPassword
    // setRootEthAddress
    // cleanupAllData (go through all keys)
    // hasBiometricAuthentication
    // authenticate(withBiometricData)
    // authenticate(withMasterPassword)
    // unlockingTime -> Time?
    // checkPassword
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

//    func test_setMasterPassword_whenWasSet_thenUserDefaultsPropertyIsSet() {
//        account.setMasterPassword("Password")
//        XCTAssertTrue(mockUserDefaults.bool(for: UserDefaultsKey.masterPasswordWasSet.rawValue) ?? false)
//    }

}

class MockUserDefaults: UserDefaultsService {

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
