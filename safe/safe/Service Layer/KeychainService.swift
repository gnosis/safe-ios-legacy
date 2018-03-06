//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol KeychainServiceProtocol {

    func password() throws -> String?
    func savePassword(_ password: String) throws
    func removePassword() throws

}

class InMemoryKeychain: KeychainServiceProtocol {

    private var storedPassword: String?

    func password() throws -> String? {
        return storedPassword
    }

    func savePassword(_ password: String) throws {
        storedPassword = password
    }

    func removePassword() throws {
        storedPassword = nil
    }

}
