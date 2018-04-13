//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import IdentityAccessDomainModel

public final class EncryptionService: EncryptionServiceProtocol {

    public typealias PrivateKey = IdentityAccessDomainModel.PrivateKey
    public typealias PublicKey = IdentityAccessDomainModel.PublicKey
    public typealias Mnemonic = IdentityAccessDomainModel.Mnemonic

    public init() {}

    public func sign(_ data: Data, _ key: PrivateKey) -> Signature {
        let sig = try! EthereumKit.Crypto.sign(hash(data), privateKey: key.data)
        return Signature(data: sig)
    }

    func hash(_ data: Data) -> Data {
        return Crypto.hashSHA3_256(data)
    }

    public func isValid(signature: Signature, for data: Data, with key: PublicKey) -> Bool {
        return Crypto.isValid(signature: signature.data,
                              of: hash(data),
                              publicKey: key.data,
                              compressed: key.isCompressed)
    }

    public func derivePrivateKey(from mnemonic: Mnemonic) -> PrivateKey {
        let seed = EthereumKit.Mnemonic.createSeed(mnemonic: mnemonic.words)
        return PrivateKey(data: HDPrivateKey(seed: seed, network: .main).raw)
    }

    public func derivePublicKey(from key: PrivateKey) -> PublicKey {
        let isCompressed = true
        return PublicKey(data: EthereumKit.Crypto.generatePublicKey(data: key.data, compressed: isCompressed),
                         compressed: isCompressed)
    }

    public func deriveEthereumAddress(from key: PublicKey) -> EthereumAddress {
        let data = EthereumKit.Address(string: EthereumKit.PublicKey(raw: key.data).generateAddress()).data
        return EthereumAddress(data: data)
    }

    public func generateMnemonic() -> Mnemonic {
        return Mnemonic(EthereumKit.Mnemonic.create())
    }

    public func encrypted(_ plainText: String) -> String {
        return plainText
    }

}
