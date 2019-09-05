//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

/// https://docs.walletconnect.org/client-sdk#send-transaction-eth_sendtransaction
public struct WCSendTransactionRequest: Decodable, Equatable, SendTransactionRequiredData {

    public var from: Address
    public var to: Address
    public var gasLimit: TokenInt?
    public var gasPrice: TokenInt?
    public var value: TokenInt
    public var data: Data
    public var nonce: String?
    public var url: WCURL!

    enum CodingKeys: String, CodingKey {
        case from
        case to
        case gasLimit
        case gasPrice
        case value
        case data
        case nonce
    }

    public init(from: Address,
                to: Address,
                gasLimit: TokenInt?,
                gasPrice: TokenInt?,
                value: TokenInt,
                data: Data,
                nonce: String?) {
        self.from = from
        self.to = to
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.value = value
        self.data = data
        self.nonce = nonce
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let from = try container.decode(String.self, forKey: .from)
        let to = try? container.decode(String.self, forKey: .to)
        let gasLimit = try? container.decode(String.self, forKey: .gasLimit)
        let gasPrice = try? container.decode(String.self, forKey: .gasPrice)
        let value = try? container.decode(String.self, forKey: .value)
        let data = try container.decode(String.self, forKey: .data)
        let nonce = try? container.decode(String.self, forKey: .nonce)

        guard let fromAddress = DomainRegistry.encryptionService.address(from: from) else {
            throw WCSendTransactionRequest.decodingError(from: decoder)
        }

        var toAddress: Address
        if let to = to {
            guard let addr = DomainRegistry.encryptionService.address(from: to) else {
                throw WCSendTransactionRequest.decodingError(from: decoder)
            }
            toAddress = addr
        } else {
            toAddress = Address.zero
        }

        self.init(from: fromAddress,
                  to: toAddress,
                  gasLimit: gasLimit != nil ? TokenInt(hex: gasLimit!)! : nil,
                  gasPrice: gasPrice != nil ? TokenInt(hex: gasPrice!)! : nil,
                  value: value != nil ? TokenInt(hex: value!)! : 0,
                  data: Data(hex: data),
                  nonce: nonce)
    }

    static func decodingError(from decoder: Decoder) -> DecodingError {
        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Value is not a valid Ethereum address")
        return DecodingError.dataCorrupted(context)
    }

}

public struct WCMessage {

    /// JSON-PRC 2.0 request/response payload as json string
    public var payload: String
    public var url: WCURL

    public init(payload: String, url: WCURL) {
        self.payload = payload
        self.url = url
    }

}
