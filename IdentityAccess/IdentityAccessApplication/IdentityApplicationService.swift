//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import IdentityAccessDomainModel

public struct RecoveryOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let mnemonic = RecoveryOptions(rawValue: 1 << 0)
}

open class IdentityApplicationService {

    private var secureStore: SecureStore { return DomainRegistry.secureStore }
    private var keyValueStore: KeyValueStore { return DomainRegistry.keyValueStore }
    private var encryptionService: EncryptionServiceProtocol { return DomainRegistry.encryptionService }

    public init() {}

    open var isRecoverySet: Bool {
        return keyValueStore.bool(for: UserDefaultsKey.isRecoveryOptionSet.rawValue) ?? false
    }

    open var configuredRecoveryOptions: RecoveryOptions {
        var options: RecoveryOptions = []
        if keyValueStore.bool(for: UserDefaultsKey.isMnemonicRecoverySet.rawValue) ?? false {
            options.insert(.mnemonic)
        }
        return options
    }

    open func getEOA() throws -> ExternallyOwnedAccount? {
        guard let mnemonic = try secureStore.mnemonic() else { return nil }
        let account = EthereumAccountFactory(service: encryptionService).account(from: mnemonic)
        return account as? ExternallyOwnedAccount
    }

    open func getOrCreateEOA() throws -> ExternallyOwnedAccount {
        if let eoa = try getEOA() {
            return eoa
        }
        let account = EthereumAccountFactory(service: encryptionService).generateAccount()
        try secureStore.saveMnemonic(account.mnemonic)
        try secureStore.savePrivateKey(account.privateKey)
        return account as! ExternallyOwnedAccount
    }

}
