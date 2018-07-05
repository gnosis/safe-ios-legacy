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

public struct EthAddress: Equatable, CustomStringConvertible {

    public static let zero = EthAddress(Data())
    private static let size = 20
    public let data: Data

    public init(_ value: Data) {
        let v = value.suffix(EthAddress.size)
        self.data = Data(repeating: 0, count: EthAddress.size - v.count) + v
    }

    public init(hex: String) {
        self.init(Data(hex: hex))
    }

    public var hexString: String {
        return data.toHexString().addHexPrefix()
    }

    public var mixedCaseChecksumEncoded: String {
        return EIP55.encode(data).addHexPrefix()
    }

    public var description: String {
        return mixedCaseChecksumEncoded
    }

}

extension EthAddress: Codable {

    enum Error: String, LocalizedError, Hashable {
        case wrongHexValue
    }

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
