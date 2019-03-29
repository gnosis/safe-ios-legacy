//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import BigInt
import Common

struct EstimateGasRequest: JSONRPCRequest {

    typealias Response = BigInt
    var method: String { return "eth_estimateGas" }
    private let transaction: TransactionCall

    public init(_ transaction: TransactionCall) {
        self.transaction = transaction
    }

    var parameters: Any? {
        return [try? OBJCJSONEncoder().encode(transaction)].compactMap { $0 }
    }

}
