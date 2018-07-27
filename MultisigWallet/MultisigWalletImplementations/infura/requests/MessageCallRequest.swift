//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit

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
            let data = try JSONEncoder().encode(transaction)
            let dict = try JSONSerialization.jsonObject(with: data, options: [])
            return [dict, blockNumber.stringValue]
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
