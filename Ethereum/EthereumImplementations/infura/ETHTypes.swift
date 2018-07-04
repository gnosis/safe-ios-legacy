//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import EthereumKit

public struct UInt256: Equatable {

    private let value: BigUInt

    /// Returns hex string representation with '0x' prefix.
    public var hexString: String {
        return String(value, radix: 16).addHexPrefix()
    }

    /// Initialize UInt256 with a value that fits into 256 bit type bounds.
    ///
    /// - Parameter value: big integer
    public init(_ value: BigUInt) {
        precondition(value.bitWidth <= 256, "Value \(value) is too big for UInt256")
        self.value = value
    }

    /// Initialize with a hex string value (string with 16 radix) with optional hex prefix '0x'.
    ///
    /// - Parameter string: hex value
    public init?(hex string: String) {
        guard let value = BigUInt(string.stripHexPrefix(), radix: 16), value.bitWidth <= 256 else { return nil }
        self.value = value
    }

}

extension UInt256: Comparable {

    public static func < (lhs: UInt256, rhs: UInt256) -> Bool {
        return lhs.value < rhs.value
    }

}

extension UInt256: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = UInt

    public init(integerLiteral value: UInt) {
        self.init(BigUInt(value))
    }

}
