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

public struct Address: Hashable {

    public let value: String

    public init(value: String) {
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
