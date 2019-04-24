//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import MultisigWalletDomainModel
import BigInt

struct GetBlockByHashRequest: JSONRPCRequest {

    typealias Response = EthBlock?

    var method: String { return "eth_getBlockByHash" }
    var parameters: Any? { return [blockHash, returnFullTransactionObjects] }
    var blockHash: String
    private let returnFullTransactionObjects = false

    func response(from resultObject: Any) throws -> EthBlock? {
        if resultObject is NSNull { return nil }
        guard let obj = resultObject as? [AnyHashable: Any] else {
            throw JSONRPCError.unexpectedTypeObject(resultObject)
        }
        guard let timestampHexString = obj["timestamp"] as? String,
            let timeBigInt = BigInt(hex: timestampHexString) else {
                throw JSONRPCExtendedError.unexpectedValue("timestamp for block \(blockHash)")
        }
        return EthBlock(hash: blockHash, timestamp: Date(timeIntervalSince1970: TimeInterval(timeBigInt)))
    }

}
