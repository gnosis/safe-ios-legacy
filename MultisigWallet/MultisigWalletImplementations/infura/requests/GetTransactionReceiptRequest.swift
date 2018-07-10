//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import MultisigWalletDomainModel

struct GetTransactionReceiptRequest: JSONRPCRequest {

    typealias Response = MultisigWalletDomainModel.TransactionReceipt?

    var method: String { return "eth_getTransactionReceipt" }
    var parameters: Any? { return [transactionHash.value] }
    var transactionHash: TransactionHash

    func response(from resultObject: Any) throws -> TransactionReceipt? {
        if resultObject is NSNull { return nil }
        guard let obj = resultObject as? [AnyHashable: Any] else {
            throw JSONRPCError.unexpectedTypeObject(resultObject)
        }
        guard let status = obj["status"] as? String else { return nil }
        return TransactionReceipt(hash: transactionHash, status: status == "0x1" ? .success : .failed)
    }

}
