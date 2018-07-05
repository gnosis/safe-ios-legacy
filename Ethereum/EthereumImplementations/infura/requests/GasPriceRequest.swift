//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import BigInt

struct GasPriceRequest: JSONRPCRequest {

    typealias Response = BigInt
    var method: String { return "eth_gasPrice" }

}
