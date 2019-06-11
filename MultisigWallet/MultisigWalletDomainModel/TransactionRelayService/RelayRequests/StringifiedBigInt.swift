//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public struct StringifiedBigInt: Hashable {

    public var value: BigInt

    public init(_ value: BigInt) {
        self.value = value
    }

    public init?(_ value: String) {
        guard let v = BigInt(value) else { return nil }
        self.value = v
    }

    public init(_ value: Int) {
        self.value = BigInt(value)
    }

}

extension StringifiedBigInt: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(value))
    }

}

extension StringifiedBigInt: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let value = BigInt(string) else {
            let error = NSError(domain: "StringifiedBigInt",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to convert BigInt from \(string)"])
            throw error
        }
        self.init(value)
    }
    
}

extension StringifiedBigInt: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: Int) {
        self.init(value)
    }

}
