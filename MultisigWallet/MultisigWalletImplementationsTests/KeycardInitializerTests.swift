//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Keycard

@available(iOS 13.1, *)
class KeycardInitializerTests: XCTestCase {

    let keycard = MockKeycardFacade()
    var initializer: KeycardInitializer!

    override func setUp() {
        super.setUp()
        initializer = KeycardInitializer(keycard: keycard)
    }

    func test_generateMasterKeyIfNeeded() throws {
        // when empty, generates master key
        let emptyKeyUIDInfo = ApplicationInfo.with(keyUID: [])
        let masterKey = Data([1, 2, 3])
        keycard.expect(call: .selectApplet, return: emptyKeyUIDInfo)
        keycard.expect(call: .generateMasterKey, return: masterKey)
        try initializer.prepareForPairing()
        XCTAssertEqual(try initializer.generateMasterKeyIfNeeded(), masterKey)

        keycard.resetExpectations()
        // when not empty, returns it from the info
        let nonEmptyKeyUIDInfo = ApplicationInfo.with(keyUID: [5, 6, 7])
        keycard.expect(call: .selectApplet, return: nonEmptyKeyUIDInfo)
        try initializer.prepareForPairing()
        XCTAssertEqual(try initializer.generateMasterKeyIfNeeded(), Data(nonEmptyKeyUIDInfo.keyUID))
    }

    func test_authenticate() throws {
        initializer.set(pin: "some", password: "some", pathComponent: 0)

        keycard.expect(call: .authenticate(pin: "some"))
        XCTAssertNoThrow(try initializer.authenticate())
        keycard.verify()

        keycard.resetExpectations()
        keycard.expect(call: .authenticate(pin: "some"), throw: CardError.wrongPIN(retryCounter: 3))
        XCTAssertThrowsError(try initializer.authenticate()) { error in
            if case KeycardDomainServiceError.invalidPin(let attempts) = error {
                XCTAssertEqual(attempts, 3)
            } else {
                XCTFail()
            }
        }

        keycard.resetExpectations()
        keycard.expect(call: .authenticate(pin: "some"), throw: CardError.wrongPIN(retryCounter: 0))
        XCTAssertThrowsError(try initializer.authenticate()) { error in
            guard case KeycardDomainServiceError.keycardBlocked = error else {
                XCTFail()
                return
            }
        }

        keycard.resetExpectations()
        keycard.expect(call: .authenticate(pin: "some"), throw: CardError.invalidAuthData)
        XCTAssertThrowsError(try initializer.authenticate()) { error in
            guard case CardError.invalidAuthData = error else {
                XCTFail()
                return
            }
        }
    }

    func test_prepareForPairing() throws {
        let info = ApplicationInfo.with(initialized: true)
        keycard.expect(call: .selectApplet, return: info)
        XCTAssertNoThrow(try initializer.prepareForPairing())
        keycard.verify()

        keycard.resetExpectations()
        keycard.expect(call: .selectApplet, throw: CardError.invalidAuthData)
        XCTAssertThrowsError(try initializer.prepareForPairing()) { error in
            guard case CardError.invalidAuthData = error else {
                XCTFail()
                return
            }
        }

        keycard.resetExpectations()
        keycard.expect(call: .selectApplet, return: ApplicationInfo.with(initialized: false))
        XCTAssertThrowsError(try initializer.prepareForPairing()) { error in
            guard case KeycardDomainServiceError.keycardNotInitialized = error else {
                XCTFail()
                return
            }
        }
    }

    func test_deriveKey() {
        let encryptionService = EncryptionService(chainId: .any, ethereumService: EthereumKitEthereumService())
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)

        let keypath =  "m/44'/60'/0'/0/1"
        let publicKey = Data(repeating: 0, count: 65)
        let address = encryptionService.address(publicKey: publicKey)
        keycard.expect(call: .exportPublicKey(path: keypath, makeCurrent: true), return: publicKey)

        initializer.set(pin: "some", password: "some", pathComponent: 1)

        XCTAssertNoThrow(try {
            let result = try self.initializer.deriveKey()
            XCTAssertEqual(result.keypath, keypath)
            XCTAssertEqual(result.publicKey, publicKey)
            XCTAssertEqual(result.address, address)
        }())
        keycard.verify()
    }

    func test_deriveKey_rethrows() {
        keycard.expect(call: .exportPublicKey(path: "m/44'/60'/0'/0/1", makeCurrent: true), throw: CardError.invalidAuthData)
        initializer.set(pin: "some", password: "some", pathComponent: 1)
        XCTAssertThrowsError(try initializer.deriveKey()) { error in
            guard case CardError.invalidAuthData = error else {
                XCTFail()
                return
            }
        }
    }
    
}

fileprivate extension ApplicationInfo {
    static func with(keyUID: [UInt8]) -> ApplicationInfo {
        return ApplicationInfo(instanceUID: [],
                               freePairingSlots: 0,
                               appVersion: 0,
                               keyUID: keyUID,
                               secureChannelPubKey: [],
                               initializedCard: true,
                               capabilities: 0)
    }

    static func with(initialized: Bool) -> ApplicationInfo {
        return ApplicationInfo(instanceUID: [],
                               freePairingSlots: 0,
                               appVersion: 0,
                               keyUID: [],
                               secureChannelPubKey: [],
                               initializedCard: initialized,
                               capabilities: 0)
    }
}

class MockKeycardFacade: KeycardFacade {

    enum API: Equatable {
        case authenticate(pin: String)
        case selectApplet
        case exportPublicKey(path: String, makeCurrent: Bool)
        case generateMasterKey
    }

    var log: [API] = []

    func resetExpectations() {
        log = []
        expectations = []
    }

    func record(call: API) {
        log.append(call)
    }

    func verify(file: StaticString = #file, line: UInt = #line) {
        var logIter = log.makeIterator()
        var expIter = expectations.makeIterator()

        while let call = logIter.next(), let expectation = expIter.next() {
            XCTAssertEqual(call, expectation.api, "Expected \(expectation.api) but called \(call)", file: file, line: line)
        }

        if log.count > expectations.count {
            XCTFail("Unexpected calls found starting with \(log.suffix(from: expectations.count)[0])", file: file, line: line)
        } else if log.count < expectations.count {
            XCTFail("Expected more calls starting with \(expectations.suffix(from: log.count)[0].api)", file: file, line: line)
        }
    }

    var expectations: [(api: API, error: Error?, returnValue: Any?)] = []

    func expect(call: API, throw error: Error? = nil, return value: Any? = nil) {
        expectations.append((call, error, value))
    }

    func throwIfNeeded(call: API) throws {
        if let expectation = expectations.first(where: { $0.api == call }), let error = expectation.error {
            throw error
        }
    }

    @discardableResult
    func returnValue<T>(for call: API) throws -> T {
        guard let expectation = expectations.first(where: { $0.api == call }) else {
            preconditionFailure("Unexpected call: \(call)")
        }
        if let error = expectation.error {
            record(call: call)
            throw error
        }
        guard let result = expectation.returnValue as? T else {
            preconditionFailure("Expected to return value of type \(T.self) but expectation uses \(String(reflecting: type(of: expectation.returnValue)))")
        }
        record(call: call)
        return result
    }

    func selectApplet() throws -> ApplicationInfo {
        try returnValue(for: .selectApplet)
    }

    func activate(pin: String, puk: String, password: String) throws {}

    var pairing: Pairing?

    func setPairing(key: Data, index: Int) {}

    func resetPairing() {}

    func pair(password: String) throws {}

    func openSecureChannel() throws {}

    func sign(hash: Data, keypath: String) throws -> Data { return Data() }

    func authenticate(pin: String) throws {
        record(call: .authenticate(pin: pin))
        try throwIfNeeded(call: .authenticate(pin: pin))
    }

    func exportPublicKey(path: String, makeCurrent: Bool) throws -> Data {
        try returnValue(for: .exportPublicKey(path: path, makeCurrent: makeCurrent))
    }

    func generateMasterKey() throws -> Data {
        return try returnValue(for: .generateMasterKey)
    }

    func unblock(puk: String, newPIN: String) throws {}

}
