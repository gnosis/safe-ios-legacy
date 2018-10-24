//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

/// Estimates gas for executing transaction with specified parameters.
/// Either recipient (to), or data, or both must be present.
/// When `to` is nil or zero address, then it is a contract creation transaction, hence `data` must not be nil or zero.
/// In other cases, `data` may be nil, but `to` must be non-zero address.
public struct EstimateTransactionRequest: Encodable {

    /// Safe address, checksummed
    public let safe: String
    /// Recipient address, checksummed
    public let to: String?
    /// Value, as base-10 integer string
    public let value: String
    /// Data, as hex string
    public let data: String?
    public let operation: WalletOperation

    public init(safe: Address,
                to: Address?,
                value: String,
                data: String?,
                operation: WalletOperation) {
        self.safe = safe.value
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

        public let safeTxGas: Int
        public let dataGas: Int
        public let gasPrice: Int
        public let signatureGas: Int
        public let lastUsedNonce: Int?
        public let gasToken: String

        public var nextNonce: Int {
            if let nonce = lastUsedNonce { return nonce + 1 }
            return 0
        }

        public var txGas: Int {
            return safeTxGas + signatureGas
        }

        public init(safeTxGas: Int,
                    dataGas: Int,
                    signatureGas: Int,
                    gasPrice: Int,
                    lastUsedNonce: Int?,
                    gasToken: String) {
            self.safeTxGas = safeTxGas
            self.dataGas = dataGas
            self.signatureGas = dataGas
            self.gasPrice = gasPrice
            self.gasToken = gasToken
            self.lastUsedNonce = lastUsedNonce
        }

    }

}
