//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import BigInt

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
    /// Derived index path. Default value is 0.
    public let derivedIndex: Int

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
                publicKey: PublicKey,
                derivedIndex: Int = 0) {
        self.address = address
        self.mnemonic = mnemonic
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.derivedIndex = derivedIndex
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
    public static let zero = Address(ethID.id)
    public static let one = Address("0x0000000000000000000000000000000000000001")
    public static let two = Address("0x0000000000000000000000000000000000000002")

    /// Creates new address with a string value.
    ///
    /// - Parameter value: string address value in hex.
    ///     Must have '0x' prefix, non-empty, equal to exactly 20 bytes in length (0x<40chars>)
    public init(_ value: String) {
        precondition(value.hasPrefix("0x"))
        precondition(Data(ethHex: value).count == 20 || Data(ethHex: value).isEmpty)
        self.value = value
    }

    public init?(rawValue: String) {
        let value = String(rawValue.trimmingCharacters(in: .whitespacesAndNewlines).prefix(42))
        let noPrefix = value.hasPrefix("0x") ? String(value.suffix(value.count - 2)) : value
        guard BigInt(noPrefix, radix: 16) != nil else { return nil }
        let data = Data(ethHex: value)
        guard data.count == 20 || data.isEmpty else { return nil }
        self.value = value
    }

}

/// Mnemonic phrase for generating private key
public struct Mnemonic: Equatable {

    /// words of the mnemonic phrase
    public let words: [String]

}

/// Private key data structure
public struct PrivateKey: Equatable {

    public let data: Data

}

/// Public key data structure
public struct PublicKey: Equatable {

    public let data: Data

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
