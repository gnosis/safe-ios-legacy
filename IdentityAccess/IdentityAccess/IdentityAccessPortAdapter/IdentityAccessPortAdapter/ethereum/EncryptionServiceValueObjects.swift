//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

struct PrivateKey {

    var data: Data

    init() { data = Data() }
    init(data: Data) { self.data = data }
}

extension PrivateKey: Equatable {

    // swiftlint:disable operator_whitespace
    static func ==(lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        return lhs.data == rhs.data
    }

}

struct PublicKey {

    var data: Data
    var isCompressed: Bool

    init() {
        self.init(data: Data(), compressed: false)
    }

    init(data: Data, compressed: Bool) {
        self.data = data
        self.isCompressed = compressed
    }

}

extension PublicKey: Equatable {

    // swiftlint:disable operator_whitespace
    static func ==(lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.data == rhs.data
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

    init(_ string: String) {
        self.words = string.components(separatedBy: " ")
    }

    func string() -> String {
        return words.joined(separator: " ")
    }

}

extension Mnemonic: Equatable {

    // swiftlint:disable operator_whitespace
    static func ==(lhs: Mnemonic, rhs: Mnemonic) -> Bool {
        return lhs.words == rhs.words
    }

}

struct EthereumAddress {

    var data: Data

}

extension EthereumAddress: Equatable {

    // swiftlint:disable operator_whitespace
    static func ==(lhs: EthereumAddress, rhs: EthereumAddress) -> Bool {
        return lhs.data == rhs.data
    }

}

struct Signature {

    var data: Data

}
