//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import IdentityAccessDomainModel

open class IdentityApplicationService {

    private var store: SecureStore { return DomainRegistry.secureStore }
    private var encryptionService: EncryptionServiceProtocol { return DomainRegistry.encryptionService }

    public init() {}

    public func getEOA() throws -> ExternallyOwnedAccount? {
        guard let mnemonic = try store.mnemonic() else { return nil }
        let account = EthereumAccountFactory(service: encryptionService).account(from: mnemonic)
        return account as? ExternallyOwnedAccount
    }

    public func getOrCreateEOA() throws -> ExternallyOwnedAccount {
        if let eoa = try getEOA() {
            return eoa
        }
        let account = EthereumAccountFactory(service: encryptionService).generateAccount()
        try store.saveMnemonic(account.mnemonic)
        try store.savePrivateKey(account.privateKey)
        return account as! ExternallyOwnedAccount
    }

}
