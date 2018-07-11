//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import CryptoSwift

public enum EthBlockNumber {
    case number(EthInt)
    case latest
    case earliest
    case pending

    public var ethIntValue: EthInt? {
        guard case .number(let value) = self else { return nil }
        return value
    }

    public var stringValue: String {
        switch self {
        case .number(let integerValue):
            return integerValue.hexString
        case .latest:
            return "latest"
        case .earliest:
            return "earliest"
        case .pending:
            return "pending"
        }
    }
}

extension EthBlockNumber: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self = .number(EthInt(integerLiteral: value))
    }

}

extension EthBlockNumber: Equatable {

    public static func ==(lhs: EthBlockNumber, rhs: EthBlockNumber) -> Bool {
        return lhs.stringValue == rhs.stringValue
    }

}

extension EthBlockNumber: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "latest": self = .latest
        case "earliest": self = .earliest
        case "pending": self = .pending
        default: self = .number(try container.decode(EthInt.self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .number(let integerValue):
            try container.encode(integerValue)
        case .latest:
            try container.encode("latest")
        case .earliest:
            try container.encode("earliest")
        case .pending:
            try container.encode("pending")
        }
    }

}
