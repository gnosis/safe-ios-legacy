//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import BigInt

struct GasPriceRequest: JSONRPCRequest {

    enum Error: Swift.Error {
        case unexpectedValue(String)
    }

    typealias Response = BigInt
    var method: String { return "eth_gasPrice" }

    func response(from resultObject: Any) throws -> BigInt {
        guard let string = resultObject as? String else {
            throw JSONRPCError.unexpectedTypeObject(resultObject)
        }
        guard let value = BigInt(hex: string) else {
            throw Error.unexpectedValue(string)
        }
        return value
    }

}
