//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

public class SecureExternallyOwnedAccountRepository: ExternallyOwnedAccountRepository {

    private let store: SecureStore

    public init (store: SecureStore) {
        self.store = store
    }

    /// NOTE: will throw exception if account already exists
    public func save(_ account: ExternallyOwnedAccount) {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let data = try! encoder.encode(account.dataStruct)
        try! store.save(data: data, forKey: account.address.value)
    }

    public func remove(address: Address) {
        try! store.removeData(forKey: address.value)
    }

    public func find(by address: Address) -> ExternallyOwnedAccount? {
        guard let data = try! store.data(forKey: address.value) else { return nil }
        let decoder = PropertyListDecoder()
        let dataStruct = try! decoder.decode(ExternallyOwnedAccountPersistedData.self, from: data)
        return ExternallyOwnedAccount(dataStruct: dataStruct)
    }

}

fileprivate struct ExternallyOwnedAccountPersistedData: Codable {

    var address: String
    var mnemonic: [String]
    var privateKey: Data
    var publicKey: Data
    var derivedIndex: Int

}

fileprivate extension ExternallyOwnedAccount {

    var dataStruct: ExternallyOwnedAccountPersistedData {
        return ExternallyOwnedAccountPersistedData(address: address.value,
                                                   mnemonic: mnemonic.words,
                                                   privateKey: privateKey.data,
                                                   publicKey: publicKey.data,
                                                   derivedIndex: derivedIndex)
    }

    convenience init(dataStruct: ExternallyOwnedAccountPersistedData) {
        self.init(address: Address(dataStruct.address),
                  mnemonic: Mnemonic(words: dataStruct.mnemonic),
                  privateKey: PrivateKey(data: dataStruct.privateKey),
                  publicKey: PublicKey(data: dataStruct.publicKey),
                  derivedIndex: dataStruct.derivedIndex)
    }

}
