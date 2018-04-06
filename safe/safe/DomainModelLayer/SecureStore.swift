//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol SecureStore {
    func password() throws -> String?
    func savePassword(_ password: String) throws
    func removePassword() throws
    func privateKey() throws -> PrivateKey?
    func savePrivateKey(_ privateKey: PrivateKey) throws
    func removePrivateKey() throws
    func mnemonic() throws -> Mnemonic?
    func saveMnemonic(_ mnemonic: Mnemonic) throws
    func removeMnemonic() throws
}
