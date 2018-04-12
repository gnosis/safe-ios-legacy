//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol EncryptionServiceProtocol {

    func generateMnemonic() -> Mnemonic
    func derivePrivateKey(from mnemonic: Mnemonic) -> PrivateKey
    func derivePublicKey(from key: PrivateKey) -> PublicKey
    func deriveEthereumAddress(from key: PublicKey) -> EthereumAddress
    func sign(_ data: Data, _ key: PrivateKey) -> Signature
    func isValid(signature: Signature, for data: Data, with key: PublicKey) -> Bool

}

public struct PrivateKey: Equatable {

    public var data: Data

    public init() { data = Data() }
    public init(data: Data) { self.data = data }

    public static func ==(lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        return lhs.data == rhs.data
    }

}

public struct PublicKey: Equatable {

    public var data: Data
    public var isCompressed: Bool

    public init() {
        self.init(data: Data(), compressed: false)
    }

    public init(data: Data, compressed: Bool) {
        self.data = data
        self.isCompressed = compressed
    }

    public static func ==(lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.data == rhs.data
    }

}

public struct Mnemonic: Equatable {

    public var words: [String]

    public init() {
        self.words = []
    }

    public init(_ words: [String]) {
        self.words = words
    }

    public init(_ string: String) {
        self.words = string.components(separatedBy: " ")
    }

    public func string() -> String {
        return words.joined(separator: " ")
    }

    public static func ==(lhs: Mnemonic, rhs: Mnemonic) -> Bool {
        return lhs.words == rhs.words
    }

}

public struct EthereumAddress: Equatable {

    public var data: Data

    public static func ==(lhs: EthereumAddress, rhs: EthereumAddress) -> Bool {
        return lhs.data == rhs.data
    }

    public init(data: Data) {
        self.data = data
    }
}

public struct Signature {

    public var data: Data

    public init(data: Data) {
        self.data = data
    }

}
