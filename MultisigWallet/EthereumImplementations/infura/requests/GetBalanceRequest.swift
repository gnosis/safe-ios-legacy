//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import EthereumKit

struct GetBalanceRequest: JSONRPCRequest {

    typealias Response = EthereumDomainModel.Ether

    enum Error: String, LocalizedError, Hashable {
        case failedToConvertResultToEther
    }

    var method: String { return "eth_getBalance" }
    var parameters: Any? { return [address, "latest"] }
    var address: String

    func response(from resultObject: Any) throws -> EthereumDomainModel.Ether {
        guard let balanceInHexWei = resultObject as? String else {
            throw JSONRPCError.unexpectedTypeObject(resultObject)
        }
        guard let result = Ether(hexAmount: balanceInHexWei) else {
            throw Error.failedToConvertResultToEther
        }
        return result
    }

}
