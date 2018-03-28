//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

class EncryptionService {

    func encrypt(_ data: String, _ key: PublicKey) -> Data {
        return data.data(using: .utf8) ?? Data()
    }

    func decrypt(_ data: Data, _ key: PrivateKey) -> Data {
        return data
    }

    func derivePrivateKey(from mnemonic: Mnemonic) -> PrivateKey? {
        return PrivateKey()
    }

    func deriveEthereumAddress(from key: PublicKey) -> EthereumAddress {
        return EthereumAddress()
    }

}
