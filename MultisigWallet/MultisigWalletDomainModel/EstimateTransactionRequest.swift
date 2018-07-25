//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

public struct EstimateTransactionRequest: Encodable {

    public let safe: String
    public let to: String
    public let value: String
    public let data: String
    public let operation: Operation

    public enum Operation: Int, Codable {
        case call
        case delegateCall
        case create
    }

    public init(safe: Address,
                to: Address,
                value: String,
                data: String,
                operation: Operation) {
        self.safe = safe.value
        self.to = to.value
        precondition(BigInt(value) != nil, "value must be a valid integer base 10, as String")
        self.value = value
        precondition(data.isEmpty || Data(ethHex: data) != Data(), "data must be a valid base 16 number, as String")
        self.data = data
        self.operation = operation
    }

    public struct Response: Decodable {

        public let safeTxGas: Int
        public let dataGas: Int
        public let gasPrice: Int
        public let gasToken: String

        public init(safeTxGas: Int,
                    dataGas: Int,
                    gasPrice: Int,
                    gasToken: String) {
            self.safeTxGas = safeTxGas
            self.dataGas = dataGas
            self.gasPrice = gasPrice
            self.gasToken = gasToken
        }

    }

}
