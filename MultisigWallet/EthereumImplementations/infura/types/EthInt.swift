//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

public struct EthInt {

    public let value: BigInt

    public init(_ value: BigInt) {
        self.value = value
    }

    public var hexString: String {
        return String(value, radix: 16).addHexPrefix()
    }

}

extension EthInt: Codable {

    public enum CodableError: Error {
        case invalidStringValue(String)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let value = BigInt(string.stripHexPrefix(), radix: 16) else {
            throw CodableError.invalidStringValue(string)
        }
        self.init(value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let string = String(value, radix: 16).addHexPrefix()
        try container.encode(string)
    }

}

extension EthInt: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self.init(BigInt(value))
    }

}
