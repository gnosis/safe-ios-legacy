//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import EthereumKit

protocol EncryptionServiceProtocol {

    func generateMnemonic() -> Mnemonic
    func derivePrivateKey(from mnemonic: Mnemonic) -> PrivateKey
    func derivePublicKey(from key: PrivateKey) -> PublicKey
    func deriveEthereumAddress(from key: PublicKey) -> EthereumAddress
    func sign(_ data: Data, _ key: PrivateKey) -> Signature
    func isValid(signature: Signature, for data: Data, with key: PublicKey) -> Bool

}

final class EncryptionService: EncryptionServiceProtocol {

    func sign(_ data: Data, _ key: PrivateKey) -> Signature {
        let sig = try! EthereumKit.Crypto.sign(hash(data), privateKey: key.data)
        return Signature(data: sig)
    }

    func hash(_ data: Data) -> Data {
        return Crypto.hashSHA3_256(data)
    }

    func isValid(signature: Signature, for data: Data, with key: PublicKey) -> Bool {
        return Crypto.isValid(signature: signature.data,
                              of: hash(data),
                              publicKey: key.data,
                              compressed: key.isCompressed)
    }

    func derivePrivateKey(from mnemonic: Mnemonic) -> PrivateKey {
        let seed = EthereumKit.Mnemonic.createSeed(mnemonic: mnemonic.words)
        return PrivateKey(data: HDPrivateKey(seed: seed, network: .main).raw)
    }

    func derivePublicKey(from key: PrivateKey) -> PublicKey {
        let isCompressed = true
        return PublicKey(data: EthereumKit.Crypto.generatePublicKey(data: key.data, compressed: isCompressed),
                         compressed: isCompressed)
    }

    func deriveEthereumAddress(from key: PublicKey) -> EthereumAddress {
        let data = EthereumKit.Address(string: EthereumKit.PublicKey(raw: key.data).generateAddress()).data
        return EthereumAddress(data: data)
    }

    func generateMnemonic() -> Mnemonic {
        return Mnemonic(EthereumKit.Mnemonic.create())
    }

}
