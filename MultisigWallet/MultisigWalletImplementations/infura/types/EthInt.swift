//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

public struct EthInt {

    public var value: BigInt
    public var encodingRadix: Int

    public init(_ value: BigInt, encodingRadix: Int = 16) {
        self.value = value
        self.encodingRadix = encodingRadix
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
        if string.hasPrefix("0x"), let base16 = BigInt(string.stripHexPrefix(), radix: 16) {
            self.init(base16, encodingRadix: 16)
        } else if !string.hasPrefix("0x"), let base10 = BigInt(string, radix: 10) {
            self.init(base10, encodingRadix: 10)
        } else {
            throw CodableError.invalidStringValue(string)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        var string = String(value, radix: encodingRadix)
        if encodingRadix == 16 {
            string = string.addHexPrefix()
        }
        try container.encode(string)
    }

}

extension EthInt: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self.init(BigInt(value))
    }

}
