//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import IdentityAccessDomainModel

open class IdentityApplicationService {

    private var secureStore: SecureStore { return DomainRegistry.secureStore }
    private var keyValueStore: KeyValueStore { return DomainRegistry.keyValueStore }
    private var encryptionService: EncryptionServiceProtocol { return DomainRegistry.encryptionService }

    public init() {}

    open func getEOA() throws -> ExternallyOwnedAccount? {
        guard let mnemonic = try secureStore.mnemonic() else { return nil }
        let account = EthereumAccountFactory(service: encryptionService).account(from: mnemonic)
        return account as? ExternallyOwnedAccount
    }

    open func getOrCreateEOA() throws -> ExternallyOwnedAccount {
        if let eoa = try getEOA() { return eoa }
        let account = EthereumAccountFactory(service: encryptionService).generateAccount()
        try secureStore.saveMnemonic(account.mnemonic)
        try secureStore.savePrivateKey(account.privateKey)
        return account as! ExternallyOwnedAccount
    }

    func getOrCreateDraftSafe() throws -> DraftSafe {
        if let draftSafe = DraftSafe.shared { return draftSafe }
        let eoa = try getOrCreateEOA()
        let paperWallet = EthereumAccountFactory(service: encryptionService).generateAccount()
        let draftSafe = DraftSafe.create(currentDeviceAddress: eoa.address, paperWallet: paperWallet)
        return draftSafe
    }

}
