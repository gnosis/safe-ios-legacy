//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import EthereumKit

public struct TransactionCall {

    public var from: EthAddress?
    public var to: EthAddress?
    public var gas: Int?
    public var gasPrice: BigInt?
    public var value: BigInt?
    public var data: Data?

}

public struct EthAddress: Equatable {

    private let value: BigInt

    public init(_ value: BigInt) {
        self.value = BigInt(clamping: 0b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111)
    }

    public init?(hex string: String) {
        guard let value = BigInt(hex: string) else { return nil }
        self.init(value)
    }

    public var data: Data {
        let valueData = BigUInt(value).serialize().suffix(20)
        return Data(repeating: 0, count: 20 - valueData.count) + valueData
    }

    public var hexString: String {
        return data.toHexString()
    }

    public var mixedCaseChecksumEncoded: String {
        return EIP55.encode(data)
    }

}

extension EthAddress: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = UInt

    public init(integerLiteral value: UInt) {
        self.init(BigInt(value))
    }

}

extension EthAddress: Codable {

    enum Error: String, LocalizedError, Hashable {
        case wrongHexValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let value = EthAddress(hex: string) else {
            throw Error.wrongHexValue
        }
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(mixedCaseChecksumEncoded)
    }

}
