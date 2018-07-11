//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import BigInt

extension JSONRPCRequest where Response == BigInt {

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
