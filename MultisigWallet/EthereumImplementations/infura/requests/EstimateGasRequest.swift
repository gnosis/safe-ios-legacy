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
            // encoding-decoding because EthereumKit expects parameters as primitive types
            // (array of arrays, dictionaries, numbers, strings or data)
            let data = try JSONEncoder().encode(transaction)
            let dict = try JSONSerialization.jsonObject(with: data, options: [])
            return [dict]
        } catch {
            return []
        }
    }

}
