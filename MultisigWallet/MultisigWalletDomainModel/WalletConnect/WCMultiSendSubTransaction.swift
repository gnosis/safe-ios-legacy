//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct WCMultiSendSubTransaction: Decodable, Equatable {

    public var to: Address
    public var value: TokenInt
    public var data: Data
    public var operation: Int

    enum CodingKeys: String, CodingKey {
        case to
        case value
        case data
        case operation
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let to = try container.decode(String.self, forKey: .to)
        let value = try container.decodeIfPresent(String.self, forKey: .value)
        let data = try container.decodeIfPresent(String.self, forKey: .data)
        let operation = try container.decodeIfPresent(Int.self, forKey: .operation)

        guard let toAddress = DomainRegistry.encryptionService.address(from: to) else {
            throw WCSendTransactionRequest.decodingError(from: decoder)
        }
        self.to = toAddress
        if let value = value {
            self.value = (value.hasPrefix("0x") ? TokenInt(hex: value) : TokenInt(value)) ?? 0
        } else {
            self.value = 0
        }
        self.data = Data(hex: data ?? "")
        self.operation = operation ?? 0
    }

}

public struct WCMultiSendRequest: Decodable, Equatable {

    public var subtransactions: [WCMultiSendSubTransaction]
    public var url: WCURL

    public init(subtransactions: [WCMultiSendSubTransaction], url: WCURL) {
        self.subtransactions = subtransactions
        self.url = url
    }

}
