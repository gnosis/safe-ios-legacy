//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Represents Ethereum's externally owned account - account controlled by private key.
public class ExternallyOwnedAccount: IdentifiableEntity<Address> {

    /// Address of the account
    public let address: Address
    /// Mnemonic phrase used to generate private key
    public let mnemonic: Mnemonic
    /// Private key that controls the account
    public let privateKey: PrivateKey
    /// Public key associated with the private key.
    public let publicKey: PublicKey

    /// Creates new account with specified parameters
    ///
    /// - Parameters:
    ///   - address: address
    ///   - mnemonic: mnemonic phrase
    ///   - privateKey: private key
    ///   - publicKey: public key
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

/// Represents Ethereum address.
public struct Address: Hashable, Codable {

    /// Address as a string
    public let value: String

    /// True if address is zero
    public var isZero: Bool {
        return self == type(of: self).zero
    }

    /// 20-byte zero address
    public static let zero = Address("0x0000000000000000000000000000000000000000")

    /// Creates new address with a string value.
    ///
    /// - Parameter value: string address value in hex.
    ///     Must have '0x' prefix, non-empty, equal to exactly 20 bytes in length (0x<40chars>)
    public init(_ value: String) {
        precondition(value.hasPrefix("0x"))
        precondition(Data(ethHex: value).count == 20 || Data(ethHex: value).isEmpty)
        self.value = value
    }

}

/// Mnemonic phrase for generating private key
public struct Mnemonic: Equatable {

    /// words of the mnemonic phrase
    public let words: [String]

    /// Creates new mnemonic with words
    ///
    /// - Parameter words: words of the mnemonic
    public init(words: [String]) {
        self.words = words
    }

}

/// Private key data structure
public struct PrivateKey: Equatable {

    public let data: Data

    public init(data: Data) {
        self.data = data
    }

}

/// Public key data structure
public struct PublicKey: Equatable {

    public let data: Data

    public init(data: Data) {
        self.data = data
    }

}

/// Represents a signed serialized ethereum transaction data structure, as a hex string.
public struct SignedRawTransaction: Equatable {

    public let value: String

    public init(_ value: String) {
        precondition(value.hasPrefix("0x"))
        precondition(!Data(ethHex: value).isEmpty)
        self.value = value
    }
}
