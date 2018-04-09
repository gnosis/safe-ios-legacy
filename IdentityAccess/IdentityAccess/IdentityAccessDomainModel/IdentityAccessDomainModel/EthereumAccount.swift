//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol EthereumAccountProtocol {

    var address: EthereumAddress { get }
    var mnemonic: Mnemonic { get }
    var privateKey: PrivateKey { get }
    var publicKey: PublicKey { get }

}

struct ExternallyOwnedAccount: EthereumAccountProtocol {

    var address: EthereumAddress
    var mnemonic: Mnemonic
    var privateKey: PrivateKey
    var publicKey: PublicKey

}

protocol EthereumAccountFactoryProtocol {

    func generateAccount() -> EthereumAccountProtocol

}

class EthereumAccountFactory: EthereumAccountFactoryProtocol {

    private let encryptionService: EncryptionServiceProtocol

    init(service: EncryptionServiceProtocol) {
        self.encryptionService = service
    }

    func generateAccount() -> EthereumAccountProtocol {
        let mnemonic = encryptionService.generateMnemonic()
        let privateKey = encryptionService.derivePrivateKey(from: mnemonic)
        let publicKey = encryptionService.derivePublicKey(from: privateKey)
        let address = encryptionService.deriveEthereumAddress(from: publicKey)
        return ExternallyOwnedAccount(address: address,
                                      mnemonic: mnemonic,
                                      privateKey: privateKey,
                                      publicKey: publicKey)
    }

}
