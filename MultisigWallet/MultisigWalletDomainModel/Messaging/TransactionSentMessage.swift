//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import CryptoSwift

public class TransactionSentMessage: OutgoingMessage {

    public let hash: Data
    public let transactionHash: TransactionHash

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
