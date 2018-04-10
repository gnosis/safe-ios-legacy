//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel
import Foundation

class UserDefaultsIntegrationTests: XCTestCase {

    var existingDefaults = [String: Any]()
    let service = UserDefaultsService()
    let testKey = "myTestKey"

    override func setUp() {
        super.setUp()
        service.deleteKey(testKey)
        // Because we don't want to spoil system defaults with these test cases
        existingDefaults = UserDefaults.currentDefaults()
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.restore(from: existingDefaults)
    }

    func test_setBool_whenNotSet_setsValue() {
        XCTAssertNil(service.bool(for: testKey))
        service.setBool(true, for: testKey)
        XCTAssertEqual(service.bool(for: testKey), true)
    }

    func test_setInt_whenNotSet_setsValue() {
        XCTAssertNil(service.int(for: testKey))
        service.setInt(1, for: testKey)
        XCTAssertEqual(service.int(for: testKey), 1)
    }

    func test_deleteKey_whenSetKey_thenRemovesIt() {
        service.setBool(true, for: testKey)
        service.deleteKey(testKey)
        XCTAssertNil(service.bool(for: testKey))
    }

}

fileprivate extension UserDefaults {

    static func currentDefaults() -> [String: Any] {
        return UserDefaults.standard.dictionaryRepresentation()
    }

    static func restore(from contents: [String: Any]) {
        let dirtyContents = UserDefaults.standard.dictionaryRepresentation()
        dirtyContents.forEach { key, _ in
            UserDefaults.standard.removeObject(forKey: key)
        }
        contents.forEach { key, value in
            UserDefaults.standard.set(value, forKey: key)
        }
    }

}

class UserDefaultsTestHelperTests: XCTestCase {

    let testKey = "userDefaultsKey"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: testKey)
    }

    func test_saveCurrentUserDefaults_savesValues() {
        UserDefaults.standard.set(true, forKey: testKey)
        defer { UserDefaults.standard.removeObject(forKey: testKey) }
        let contents = UserDefaults.currentDefaults()
        XCTAssertEqual(contents[testKey] as? Bool, true)
    }

    func test_restoreUserDefaults_removesTestValues() {
        let contents = UserDefaults.currentDefaults()
        UserDefaults.standard.set(true, forKey: testKey)
        defer { UserDefaults.standard.removeObject(forKey: testKey) }
        UserDefaults.restore(from: contents)
        XCTAssertNil(UserDefaults.standard.value(forKey: testKey))
    }

    func test_restoreUserDefaults_restoresSavedValues() {
        UserDefaults.standard.set(true, forKey: testKey)
        defer { UserDefaults.standard.removeObject(forKey: testKey) }
        let contents = UserDefaults.currentDefaults()
        UserDefaults.restore(from: contents)
        XCTAssertEqual(UserDefaults.standard.bool(forKey: testKey), true)
    }

}
