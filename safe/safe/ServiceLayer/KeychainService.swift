//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol KeychainServiceProtocol {

    func password() throws -> String?
    func savePassword(_ password: String) throws
    func removePassword() throws
    func privateKey() throws -> PrivateKey?
    func savePrivateKey(_ privateKey: PrivateKey) throws
    func removePrivateKey() throws

}

enum KeychainError: Error {
    case unexpectedPasswordData
    // https://www.osstatus.com
    case unhandledError(status: OSStatus)
}

final class KeychainService: KeychainServiceProtocol {

    private static let defaultServiceName = "pm.gnosis.safe"
    private let serviceName: String

    init(identifier: String = KeychainService.defaultServiceName) {
        serviceName = identifier
    }

    private func get(query: [String: Any]) throws -> CFTypeRef? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        return item
    }

    private func add(query: [String: Any]) throws {
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    private func remove(query: [String: Any]) throws {
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    // MARK: - Password

    func password() throws -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: serviceName,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]


        guard let existingItem = try get(query: query) as? [String: Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                return nil
        }
        return password
    }

    func savePassword(_ password: String) throws {
        guard let password = password.data(using: String.Encoding.utf8) else {
            throw KeychainError.unexpectedPasswordData
        }
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: serviceName,
                                    kSecValueData as String: password]
        try add(query: query)
    }

    func removePassword() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: serviceName]
        try remove(query: query)
    }

    // MARK: - Private Key

    func privateKey() throws -> PrivateKey? {
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        guard let existingItem = try get(query: query) as? [String: Any],
            let data = existingItem[kSecValueData as String] as? Data else { return nil }
        return PrivateKey(data: data)
    }

    func savePrivateKey(_ privateKey: PrivateKey) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecValueData as String: privateKey.data]
        try add(query: query)
    }

    func removePrivateKey() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassKey]
        try remove(query: query)
    }

}
