//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import Common

struct MessageCallRequest: JSONRPCRequest {

    typealias Response = Data
    var method: String { return "eth_call" }
    private let transaction: TransactionCall
    private let blockNumber: EthBlockNumber

    public init(_ transaction: TransactionCall, _ blockNumber: EthBlockNumber) {
        self.transaction = transaction
        self.blockNumber = blockNumber
    }

    var parameters: Any? {
        do {
            let json = try OBJCJSONEncoder().encode(transaction)
            return [json, blockNumber.stringValue]
        } catch {
            return []
        }
    }

    func response(from resultObject: Any) throws -> Data {
        guard let string = resultObject as? String else {
            throw JSONRPCError.unexpectedTypeObject(resultObject)
        }
        return Data(ethHex: string)
    }

}
