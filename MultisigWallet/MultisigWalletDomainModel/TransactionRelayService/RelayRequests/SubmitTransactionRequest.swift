//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

/// Request to submit transaction to the blockchain
public class SubmitTransactionRequest: Encodable {

    /// Sender (safe) address, checksummed
    public let safe: String
    /// Recipient address, checksummed
    public let to: String
    /// Amount, as base-10 integer string
    public let value: String
    /// Hex value or empty string
    public let data: String
    public let operation: WalletOperation
    /// Signatures, sorted lexicographically by their signer's address
    public let signatures: [EthSignature]
    /// gas amount from transaction estimation, base-10 integer string
    public let safeTxGas: String
    /// data gas amount from transaction estimation, base-10 integer string
    public let dataGas: String
    /// gas price from transaction estimation, base-10 integer string
    public let gasPrice: String
    /// gas token address. Zero address for ETH. Currently not supported by server-side.
    public let gasToken: String?
    /// Safe contract nonce, as base-10 integer string. Fetched by call to `nonce()` getter method of the contract.
    public let nonce: String

    /// Creates new request
    ///
    /// - Parameters:
    ///   - transaction: transaction to submit to blockchain
    ///   - signatures: transaction signatures from owners, sorted by owner address lexicographically.
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
