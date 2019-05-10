//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import MultisigWalletDomainModel
import BigInt

struct GetStorageAtRequest: JSONRPCRequest {

    typealias Response = Data

    var method: String { return "eth_getStorageAt" }

    private let address: EthAddress
    private let position: Int
    private let blockNumber: EthBlockNumber

    public init(address: EthAddress, position: Int, blockNumber: EthBlockNumber) {
        self.address = address
        self.position = position
        self.blockNumber = blockNumber
    }

    var parameters: Any? {
        return [address.hexString, BigInt(position).hexString, blockNumber.stringValue]
    }

    func response(from resultObject: Any) throws -> Data {
        guard let string = resultObject as? String else {
            throw JSONRPCError.unexpectedTypeObject(resultObject)
        }
        return Data(ethHex: string)
    }

}
