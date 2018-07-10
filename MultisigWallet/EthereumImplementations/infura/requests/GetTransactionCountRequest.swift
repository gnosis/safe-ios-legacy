//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import BigInt

struct GetTransactionCountRequest: JSONRPCRequest {

    typealias Response = BigInt
    var method: String { return "eth_getTransactionCount" }
    var parameters: Any? { return [address.hexString, blockNumber.stringValue] }

    let address: EthAddress
    let blockNumber: EthBlockNumber

    init(_ address: EthAddress, _ blockNumber: EthBlockNumber) {
        self.address = address
        self.blockNumber = blockNumber
    }

}
