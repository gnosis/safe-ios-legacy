//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit

struct GasPriceRequest: JSONRPCRequest {

    enum Error: Swift.Error {
        case unexpectedValue(String)
    }

    typealias Response = UInt256
    var method: String { return "eth_gasPrice" }

    func response(from resultObject: Any) throws -> UInt256 {
        guard let string = resultObject as? String else {
            throw JSONRPCError.unexpectedTypeObject(resultObject)
        }
        guard let value = UInt256(hex: string) else {
            throw Error.unexpectedValue(string)
        }
        return value
    }

}
