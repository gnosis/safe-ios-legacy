//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import EthereumKit

struct GetBalanceRequest: JSONRPCRequest {

    typealias Response = BigInt

    var method: String { return "eth_getBalance" }
    var parameters: Any? { return [address.hexString, blockNumber.stringValue] }
    var address: EthAddress
    var blockNumber: EthBlockNumber

    public init(_ address: EthAddress, _ blockNumber: EthBlockNumber) {
        self.address = address
        self.blockNumber = blockNumber
    }

}
