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
