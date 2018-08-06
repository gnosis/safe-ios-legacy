//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

public class SubmitTransactionRequest: Encodable {

    public let safe: String
    public let to: String
    public let value: String
    public let data: String
    public let operation: WalletOperation
    public let signatures: [EthSignature]
    public let safeTxGas: String
    public let dataGas: String
    public let gasPrice: String
    public let gasToken: String?
    public let nonce: String

    public init(transaction: Transaction, signatures: [EthSignature]) {
        safe = transaction.sender!.value
        to = transaction.recipient!.value
        value = String(transaction.amount!.amount)
        data = transaction.data?.toHexString() ?? ""
        operation = transaction.operation!
        self.signatures = signatures
        safeTxGas = String(transaction.feeEstimate!.gas)
        dataGas = String(transaction.feeEstimate!.dataGas)
        gasPrice = String(transaction.feeEstimate!.gasPrice.amount)
        gasToken = nil
        nonce = transaction.nonce!
    }

    public struct Response: Decodable {

        public let transactionHash: String

        public init(transactionHash: String) {
            self.transactionHash = transactionHash
        }

    }

}
