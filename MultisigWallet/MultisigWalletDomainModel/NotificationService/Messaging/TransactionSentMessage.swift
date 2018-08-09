//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import CryptoSwift

/// Notifies recipient that new transaction was accepted by the blockchain.
public class TransactionSentMessage: OutgoingMessage {

    /// Transaction hash, according to ERC191
    public let hash: Data
    /// Ethereum transaction hash
    public let transactionHash: TransactionHash

    /// Creates new TransactionSentMessage with specified parameters
    ///
    /// - Parameters:
    ///   - to: recipient address
    ///   - from: sender address
    ///   - hash: ERC191 hash of a transaction
    ///   - transactionHash: Ethereum hash of a transaction
    public required init(to: Address, from: Address, hash: Data, transactionHash: TransactionHash) {
        self.hash = hash
        self.transactionHash = transactionHash
        super.init(type: "sendTransactionHash", to: to, from: from)
    }

    private struct JSON: Encodable {
        var type: String
        var hash: String
        var chainHash: String
    }

    public override var stringValue: String {
        let json = JSON(type: type, hash: "0x" + hash.toHexString(), chainHash: transactionHash.value)
        return jsonString(from: json)
    }

}
