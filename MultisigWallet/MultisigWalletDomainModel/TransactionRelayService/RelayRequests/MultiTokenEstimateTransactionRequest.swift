//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

public struct MultiTokenEstimateTransactionRequest: Encodable {

    public let safe: String
    public let to: String?
    public let value: String
    public let data: String?
    public let operation: WalletOperation

    public init(safe: String,
                to: Address?,
                value: String,
                data: String?,
                operation: WalletOperation) {
        self.safe = safe
        self.to = to?.value
        precondition(BigInt(value) != nil, "value must be a valid integer base 10, as String")
        self.value = value
        if let data = data {
            precondition(data.isEmpty || Data(ethHex: data) != Data(), "data must be a valid base 16 number, as String")
            self.data = data
        } else {
            self.data = nil
        }
        self.operation = operation
    }

    public struct Response: Decodable {

        public let lastUsedNonce: Int?
        public let safeTxGas: Int?
        public let operationalGas: Int?
        public let estimations: [Estimation]

        public var nextNonce: Int {
            if let nonce = lastUsedNonce { return nonce + 1 }
            return 0
        }

        public init(lastUsedNonce: Int?, safeTxGas: Int?, operationalGas: Int?, estimations: [Estimation]) {
            self.lastUsedNonce = lastUsedNonce
            self.estimations = estimations
            self.safeTxGas = safeTxGas
            self.operationalGas = operationalGas
        }

        // Estimations in the response won't have the safeTxGas and operationalGas - they are in the parent Response
        // object. We augment the estimations with these values as they are the same for all estimations.
        public struct Estimation: Decodable {

            public let gasToken: String
            public let gasPrice: Int
            public let baseGas: Int
            public let safeTxGas: Int!
            public let operationalGas: Int!

            public init(gasToken: String,
                        gasPrice: Int,
                        safeTxGas: Int,
                        baseGas: Int,
                        operationalGas: Int) {
                self.gasToken = gasToken
                self.gasPrice = gasPrice
                self.safeTxGas = safeTxGas
                self.baseGas = baseGas
                self.operationalGas = operationalGas
            }

            /// The value displayed to user includes operationalGas parameter.
            public var totalDisplayedToUser: BigInt {
                return BigInt(gasPrice) * (BigInt(baseGas) + BigInt(safeTxGas) + BigInt(operationalGas))
            }

        }

    }

}
