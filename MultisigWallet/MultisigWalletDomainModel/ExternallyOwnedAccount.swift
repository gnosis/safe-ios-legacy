//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class ExternallyOwnedAccount: IdentifiableEntity<Address> {

    public let address: Address
    public let mnemonic: Mnemonic
    public let privateKey: PrivateKey
    public let publicKey: PublicKey

    public init(address: Address,
                mnemonic: Mnemonic,
                privateKey: PrivateKey,
                publicKey: PublicKey) {
        self.address = address
        self.mnemonic = mnemonic
        self.privateKey = privateKey
        self.publicKey = publicKey
        super.init(id: address)
    }

}

public struct Address: Hashable, Codable {

    public let value: String

    public var isZero: Bool {
        return self == type(of: self).zero
    }

    public static let zero = Address("0x0000000000000000000000000000000000000000")

    public init(_ value: String) {
        precondition(value.hasPrefix("0x"))
        precondition(Data(ethHex: value).count == 20 || Data(ethHex: value).isEmpty)
        self.value = value
    }

}

public struct Mnemonic: Equatable {

    public let words: [String]

    public init(words: [String]) {
        self.words = words
    }

}

public struct PrivateKey: Equatable {

    public let data: Data

    public init(data: Data) {
        self.data = data
    }

}

public struct PublicKey: Equatable {

    public let data: Data

    public init(data: Data) {
        self.data = data
    }

}

public struct SignedRawTransaction: Equatable {

    public let value: String

    public init(_ value: String) {
        precondition(value.hasPrefix("0x"))
        precondition(!Data(ethHex: value).isEmpty)
        self.value = value
    }
}
