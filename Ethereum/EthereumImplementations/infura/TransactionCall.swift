//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import EthereumKit

public struct TransactionCall: Codable {

    public var from: EthAddress?
    public var to: EthAddress?
    public var gas: Int?
    public var gasPrice: BigInt?
    public var value: BigInt?
    public var data: EthData?

}

public struct EthAddress: Equatable, CustomStringConvertible {

    public static let zero = EthAddress(Data())
    private static let size = 20
    private let ethData: EthData

    public init(_ value: EthData) {
        ethData = value.padded(to: EthAddress.size)
    }

    public init(_ value: Data) {
        self.init(EthData(value))
    }

    public init(hex: String) {
        self.init(EthData(hex: hex))
    }

    public var data: Data {
        return ethData.data
    }

    public var hexString: String {
        return ethData.hexString
    }

    public var mixedCaseChecksumEncoded: String {
        return EIP55.encode(data).addHexPrefix()
    }

    public var description: String {
        return mixedCaseChecksumEncoded
    }

}

extension EthAddress: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(hex: string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(mixedCaseChecksumEncoded)
    }

}

public struct EthData: Equatable, CustomStringConvertible {

    public let data: Data

    public init(_ value: Data) {
        self.data = value
    }

    public init(hex: String) {
        self.init(Data(hex: hex))
    }

    public var hexString: String {
        return data.toHexString().addHexPrefix()
    }

    public var description: String {
        return hexString
    }

    public func padded(to count: Int) -> EthData {
        if data.count >= count { return EthData(data.suffix(count)) }
        return EthData(Data(repeating: 0, count: count - data.count) + data)
    }

}

extension EthData: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(hex: string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(hexString)
    }

}
