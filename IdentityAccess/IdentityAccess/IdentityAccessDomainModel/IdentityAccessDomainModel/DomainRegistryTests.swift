//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel
import IdentityAccessPortAdapterTestSupport

class DomainRegistryTests: XCTestCase {

    func test_exists() {
        DomainRegistry.put(service: InMemoryKeyValueStore(), for: KeyValueStore.self)
        DomainRegistry.put(service: MockKeychain(), for: SecureStore.self)
        DomainRegistry.put(service: MockBiometricService(), for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: MockClockService(), for: Clock.self)
        DomainRegistry.put(service: MockLogger(), for: Logger.self)
        DomainRegistry.put(service: MockEncryptionService(), for: EncryptionServiceProtocol.self)
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

class MockEncryptionService: EncryptionServiceProtocol {

    func generateMnemonic() -> Mnemonic { return Mnemonic("test") }

    func derivePrivateKey(from mnemonic: Mnemonic) -> PrivateKey { return PrivateKey(data: Data()) }

    func derivePublicKey(from key: PrivateKey) -> PublicKey { return PublicKey(data: Data(), compressed: true) }

    func deriveEthereumAddress(from key: PublicKey) -> EthereumAddress { return EthereumAddress(data: Data()) }

    func sign(_ data: Data, _ key: PrivateKey) -> Signature { return Signature(data: Data()) }

    func isValid(signature: Signature, for data: Data, with key: PublicKey) -> Bool { return true }

}
