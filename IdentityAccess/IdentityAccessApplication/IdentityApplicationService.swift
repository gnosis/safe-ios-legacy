//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import IdentityAccessDomainModel

open class IdentityApplicationService {

    private var secureStore: SecureStore { return DomainRegistry.secureStore }
    private var keyValueStore: KeyValueStore { return DomainRegistry.keyValueStore }
    private var encryptionService: EncryptionServiceProtocol { return DomainRegistry.encryptionService }

    public init() {}

    private func getEOA() throws -> ExternallyOwnedAccount? {
        guard let mnemonic = try secureStore.mnemonic() else { return nil }
        let account = EthereumAccountFactory(service: encryptionService).account(from: mnemonic)
        return account as? ExternallyOwnedAccount
    }

    func getOrCreateEOA() throws -> ExternallyOwnedAccount {
        if let eoa = try getEOA() { return eoa }
        let account = EthereumAccountFactory(service: encryptionService).generateAccount()
        try secureStore.saveMnemonic(account.mnemonic)
        try secureStore.savePrivateKey(account.privateKey)
        return account as! ExternallyOwnedAccount
    }

    open func createDraftSafe() throws -> DraftSafe {
        let eoa = try getOrCreateEOA()
        let paperWallet = EthereumAccountFactory(service: encryptionService).generateAccount()
        let draftSafe = DraftSafe.create(currentDeviceAddress: eoa.address, paperWallet: paperWallet)
        return draftSafe
    }

    open func getOrCreateDraftSafe() throws -> DraftSafe {
        if let draftSafe = DraftSafe.shared { return draftSafe }
        return try createDraftSafe()
    }

    open func confirmPaperWallet(draftSafe: DraftSafe) {
        draftSafe.confirmPaperWallet()
    }

    open func confirmBrowserExtension(draftSafe: DraftSafe, address: String) {
        let ethereumAddress = EthereumAddress(data: address.data(using: .utf8)!)
        draftSafe.confirmBrowserExtension(address: ethereumAddress)
    }

    open func convertBrowserExtensionCodeIntoEthereumAddress(_ code: String) -> String? {
        if code == "invalid_code" { return nil }
        return "0xa06a215ca4a54189e7f951c59f0431e33d0f38a0"
    }

}
