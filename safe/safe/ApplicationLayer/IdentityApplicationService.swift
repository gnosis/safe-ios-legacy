//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

class IdentityApplicationService {

    var store: SecureStore { return DomainRegistry.secureStore }
    let encryptionService = EncryptionService()

    func getEOA() throws -> ExternallyOwnedAccount? {
        guard let mnemonic = try store.mnemonic() else { return nil }
        let account = EthereumAccountFactory(service: encryptionService).account(from: mnemonic)
        return account as? ExternallyOwnedAccount
    }

    func getOrCreateEOA() throws -> ExternallyOwnedAccount {
        if let eoa = try getEOA() {
            return eoa
        }
        let account = EthereumAccountFactory(service: encryptionService).generateAccount()
        // TODO: save account in one call
        try store.saveMnemonic(account.mnemonic)
        try store.savePrivateKey(account.privateKey)
        return account as! ExternallyOwnedAccount
    }

}
