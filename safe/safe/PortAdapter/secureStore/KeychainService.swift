//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

enum KeychainError: Error {
    case unexpectedPasswordData
    // https://www.osstatus.com
    case unhandledError(status: OSStatus)
}

final class KeychainService: SecureStore {

    private static let defaultServiceName = "pm.gnosis.safe"
    private let serviceName: String

    init(identifier: String = KeychainService.defaultServiceName) {
        serviceName = identifier
    }

    func password() throws -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: serviceName,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        guard let existingItem = item as? [String: Any],
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
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func removePassword() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: serviceName]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

}
