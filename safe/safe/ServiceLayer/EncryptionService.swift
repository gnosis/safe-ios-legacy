//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import EthereumKit

protocol EncryptionServiceProtocol {

    func encrypt(_ data: String, _ key: PublicKey) -> Data

    func decrypt(_ data: Data, _ key: PrivateKey) -> Data

    func derivePrivateKey(from mnemonic: Mnemonic) -> PrivateKey?

    func deriveEthereumAddress(from key: PublicKey) -> EthereumAddress

    func generateMnemonic() -> Mnemonic

}

final class EncryptionService {

    func encrypt(_ data: String, _ key: PublicKey) -> Data {
        return data.data(using: .utf8) ?? Data()
    }

    func decrypt(_ data: Data, _ key: PrivateKey) -> Data {
        return data
    }

    func derivePrivateKey(from mnemonic: Mnemonic) -> PrivateKey? {
        let seed = EthereumKit.Mnemonic.createSeed(mnemonic: mnemonic.words)
        return PrivateKey(data: HDPrivateKey(seed: seed, network: .main).raw)
    }

    func deriveEthereumAddress(from key: PublicKey) -> EthereumAddress {
        return EthereumAddress()
    }

    func generateMnemonic() -> Mnemonic {
        return Mnemonic(EthereumKit.Mnemonic.create())
    }

}
