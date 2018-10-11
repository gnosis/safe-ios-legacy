//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class SafeOwnerManagerContractProxy: EthereumContractProxy {

    public func getOwners() throws -> [Address] {
        return try decodeArrayAddress(invoke("getOwners()"))
    }

    public func isOwner(_ address: Address) throws -> Bool {
        return try decodeBool(invoke("isOwner(address)", encodeAddress(address)))
    }

    public func getThreshold() throws -> Int {
        return try Int(decodeUInt(invoke("getThreshold()")))
    }

    public func nonce() throws -> BigUInt {
        return try decodeUInt(invoke("nonce()"))
    }

    public func addOwner(_ address: Address, newThreshold threshold: Int) -> Data {
        return invocation("addOwnerWithThreshold(address,uint256)",
                          encodeAddress(address),
                          encodeUInt(BigUInt(threshold)))
    }

}
