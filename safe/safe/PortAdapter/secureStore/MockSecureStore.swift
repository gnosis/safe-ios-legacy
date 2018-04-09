//
//  Copyright © 2018 Gnosis. All rights reserved.
//

@testable import safe

class MockSecureStore: SecureStore {

    var storedPassword: String?
    var storedMnemonic: Mnemonic?
    var storedPrivateKey: PrivateKey?

    var shouldThrow: Bool = false

    private func throwIfNeeded() throws {
        if shouldThrow { throw TestError.error }
    }

    func password() throws -> String? {
        try throwIfNeeded()
        return storedPassword
    }

    func savePassword(_ password: String) throws {
        try throwIfNeeded()
        storedPassword = password
    }

    func removePassword() throws {
        try throwIfNeeded()
        storedPassword = nil
    }

    func privateKey() throws -> PrivateKey? {
        try throwIfNeeded()
        return storedPrivateKey
    }

    func savePrivateKey(_ privateKey: PrivateKey) throws {
        try throwIfNeeded()
        storedPrivateKey = privateKey
    }

    func removePrivateKey() throws {
        try throwIfNeeded()
        storedPrivateKey = nil
    }

    func mnemonic() throws -> Mnemonic? {
        try throwIfNeeded()
        return storedMnemonic
    }

    func saveMnemonic(_ mnemonic: Mnemonic) throws {
        try throwIfNeeded()
        storedMnemonic = mnemonic
    }

    func removeMnemonic() throws {
        try throwIfNeeded()
        storedMnemonic = nil
    }

}
