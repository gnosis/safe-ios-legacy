//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

public protocol EthereumAccountProtocol {

    var address: EthereumAddress { get }
    var mnemonic: Mnemonic { get }
    var privateKey: PrivateKey { get }
    var publicKey: PublicKey { get }

}

public struct ExternallyOwnedAccount: EthereumAccountProtocol {

    public var address: EthereumAddress
    public var mnemonic: Mnemonic
    public var privateKey: PrivateKey
    public var publicKey: PublicKey

}

extension ExternallyOwnedAccount: Equatable {

    // swiftlint:disable operator_whitespace
    public static func ==(lhs: ExternallyOwnedAccount, rhs: ExternallyOwnedAccount) -> Bool {
        return lhs.address == rhs.address &&
            lhs.mnemonic == rhs.mnemonic &&
            lhs.privateKey == rhs.privateKey &&
            lhs.publicKey == rhs.publicKey
    }

}

public protocol EthereumAccountFactoryProtocol {

    func generateAccount() -> EthereumAccountProtocol

}

public class EthereumAccountFactory: EthereumAccountFactoryProtocol {

    private let encryptionService: EncryptionServiceProtocol

    public init(service: EncryptionServiceProtocol) {
        self.encryptionService = service
    }

    public func generateAccount() -> EthereumAccountProtocol {
        let mnemonic = encryptionService.generateMnemonic()
        return account(from: mnemonic)
    }

    public func account(from mnemonic: Mnemonic) -> EthereumAccountProtocol {
        let privateKey = encryptionService.derivePrivateKey(from: mnemonic)
        let publicKey = encryptionService.derivePublicKey(from: privateKey)
        let address = encryptionService.deriveEthereumAddress(from: publicKey)
        return ExternallyOwnedAccount(address: address,
                                      mnemonic: mnemonic,
                                      privateKey: privateKey,
                                      publicKey: publicKey)
    }

}
