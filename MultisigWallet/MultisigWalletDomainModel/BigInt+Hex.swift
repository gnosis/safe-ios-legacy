//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public extension BigInt {

    /// Initialize with a hex value
    init?(hex string: String) {
        self.init(string.stripHexPrefix(), radix: 16)
    }

    /// Returns hex string representation with '0x' prefix.
    var hexString: String {
        return String(self, radix: 16).addHexPrefix()
    }

}

public extension BigUInt {

    /// Initialize with a hex value
    init?(hex string: String) {
        self.init(string.stripHexPrefix(), radix: 16)
    }

    /// Returns hex string representation with '0x' prefix.
    var hexString: String {
        return String(self, radix: 16).addHexPrefix()
    }

}

fileprivate extension String {

    func stripHexPrefix() -> String {
        var hex = self
        let prefix = "0x"
        if hex.hasPrefix(prefix) {
            hex = String(hex.dropFirst(prefix.count))
        }
        return hex
    }

    func addHexPrefix() -> String {
        return "0x".appending(self)
    }

}
