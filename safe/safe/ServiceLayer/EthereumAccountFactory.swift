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

struct EthereumAddress {}

extension EthereumAddress: Equatable {

    // swiftlint:disable operator_whitespace
    static func ==(lhs: EthereumAddress, rhs: EthereumAddress) -> Bool {
        return true
    }

}

struct Mnemonic {

    var words: [String]

    init() {
        self.words = []
    }

    init(_ words: [String]) {
        self.words = words
    }

}

struct PrivateKey {

    var data: Data

    init() { data = Data() }
    init(data: Data) { self.data = data }
}

extension PrivateKey: Equatable {

    // swiftlint:disable operator_whitespace
    static func ==(lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        return true
    }

}

struct PublicKey {}

extension PublicKey: Equatable {

    // swiftlint:disable operator_whitespace
    static func ==(lhs: PublicKey, rhs: PublicKey) -> Bool {
        return true
    }

}

struct FakeAccount: EthereumAccountProtocol {

    var address: EthereumAddress
    var mnemonic: Mnemonic
    var privateKey: PrivateKey
    var publicKey: PublicKey

    init() {
        address = EthereumAddress()
        mnemonic = Mnemonic()
        privateKey = PrivateKey()
        publicKey = PublicKey()
    }

}

protocol EthereumAccountFactoryProtocol {

    func generateAccount() -> EthereumAccountProtocol

}

class EthereumAccountFactory: EthereumAccountFactoryProtocol {

    func generateAccount() -> EthereumAccountProtocol {
        return FakeAccount()
    }

}
