//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class DomainRegistryTests: XCTestCase {

    func test_exists() {
        DomainRegistry.put(service: InMemoryKeyValueStore(), for: KeyValueStore.self)
        DomainRegistry.put(service: MockKeychain(), for: SecureStore.self)
        DomainRegistry.put(service: MockBiometricService(), for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: MockClockService(), for: Clock.self)
        DomainRegistry.put(service: MockLogger(), for: Logger.self)
        XCTAssertNotNil(DomainRegistry.keyValueStore)
        XCTAssertNotNil(DomainRegistry.secureStore)
        XCTAssertNotNil(DomainRegistry.biometricAuthenticationService)
        XCTAssertNotNil(DomainRegistry.clock)
        XCTAssertNotNil(DomainRegistry.logger)
    }

    func test_defaultValues() {
        XCTAssertNotNil(DomainRegistry.keyValueStore)
        XCTAssertNotNil(DomainRegistry.secureStore)
        XCTAssertNotNil(DomainRegistry.biometricAuthenticationService)
        XCTAssertNotNil(DomainRegistry.clock)
        XCTAssertNotNil(DomainRegistry.logger)
    }

}

class MockLogger: Logger {

    func fatal(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString) {
        print(file, function, line, message, error == nil ? "" : error!)
    }

    func error(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString) {
        print(file, function, line, message, error == nil ? "" : error!)
    }

    func info(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString) {
        print(file, function, line, message, error == nil ? "" : error!)
    }

    func debug(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString) {
        print(file, function, line, message, error == nil ? "" : error!)
    }

}

class InMemoryKeyValueStore: KeyValueStore {

    private var store = [String: Any]()

    func bool(for key: String) -> Bool? {
        return get(key)
    }

    func setBool(_ value: Bool, for key: String) {
        set(value, key)
    }

    func int(for key: String) -> Int? {
        return get(key)
    }

    func setInt(_ value: Int, for key: String) {
        set(value, key)
    }

    func deleteKey(_ key: String) {
        store.removeValue(forKey: key)
    }

    private func get<T>(_ key: String) -> T? {
        return store[key] as? T
    }

    private func set<T>(_ value: T, _ key: String) {
        store[key] = value
    }

}
