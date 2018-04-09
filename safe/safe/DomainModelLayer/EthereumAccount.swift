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

extension ExternallyOwnedAccount: Equatable {

    // swiftlint:disable operator_whitespace
    static func ==(lhs: ExternallyOwnedAccount, rhs: ExternallyOwnedAccount) -> Bool {
        return lhs.address == rhs.address &&
            lhs.mnemonic == rhs.mnemonic &&
            lhs.privateKey == rhs.privateKey &&
            lhs.publicKey == rhs.publicKey
    }

}

protocol EthereumAccountFactoryProtocol {

    func generateAccount() -> EthereumAccountProtocol

}

class EthereumAccountFactory: EthereumAccountFactoryProtocol {

    private let encryptionService: EncryptionServiceProtocol

    init(service: EncryptionServiceProtocol = EncryptionService()) {
        self.encryptionService = service
    }

    func generateAccount() -> EthereumAccountProtocol {
        let mnemonic = encryptionService.generateMnemonic()
        return account(from: mnemonic)
    }

    func account(from mnemonic: Mnemonic) -> EthereumAccountProtocol {
        let privateKey = encryptionService.derivePrivateKey(from: mnemonic)
        let publicKey = encryptionService.derivePublicKey(from: privateKey)
        let address = encryptionService.deriveEthereumAddress(from: publicKey)
        return ExternallyOwnedAccount(address: address,
                                      mnemonic: mnemonic,
                                      privateKey: privateKey,
                                      publicKey: publicKey)
    }

}
