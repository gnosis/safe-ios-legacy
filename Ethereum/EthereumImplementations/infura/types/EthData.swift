//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import CryptoSwift

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

