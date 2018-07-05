//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import BigInt

struct EstimateGasRequest: JSONRPCRequest {

    typealias Response = BigInt
    var method: String { return "eth_estimateGas" }
    private let transaction: TransactionCall

    public init(_ transaction: TransactionCall) {
        self.transaction = transaction
    }

    var parameters: Any? {
        do {
            let data = try JSONEncoder().encode(transaction)
            let dict = try JSONSerialization.jsonObject(with: data, options: [])
            return [dict]
        } catch {
            return []
        }
    }

    func response(from resultObject: Any) throws -> BigInt {
        guard let string = resultObject as? String else {
            throw JSONRPCError.unexpectedTypeObject(resultObject)
        }
        guard let value = BigInt(hex: string) else {
            throw JSONRPCExtendedError.unexpectedValue(string)
        }
        return value
    }

}
