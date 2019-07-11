//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

/// https://docs.walletconnect.org/client-sdk#send-transaction-eth_sendtransaction
public struct WCSendTransactionRequest: Decodable, Equatable {

    public var from: String
    public var to: String
    public var gasLimit: String
    public var gasPrice: String
    public var value: String
    public var data: String
    public var nonce: String

    public init(from: String,
                to: String,
                gasLimit: String,
                gasPrice: String,
                value: String,
                data: String,
                nonce: String) {
        self.from = from
        self.to = to
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.value = value
        self.data = data
        self.nonce = nonce
    }

}

// TODO: remove if we don't need handling of Ethereum JSON-RPC requests.
public struct WCMessage {

    /// JSON-PRC 2.0 request/response payload as json string
    public var payload: String
    public var url: WCURL

    public init(payload: String, url: WCURL) {
        self.payload = payload
        self.url = url
    }

}
