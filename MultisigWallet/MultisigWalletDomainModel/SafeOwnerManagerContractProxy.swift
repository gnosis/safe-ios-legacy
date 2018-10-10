//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class SafeOwnerManagerContractProxy: EthereumContractProxy {

    private var contract: Address

    public init(_ address: Address) {
        contract = address
    }

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

    private func invoke(_ selector: String, _ args: Data ...) throws -> Data {
        let invocation = method(selector) + args.reduce(into: Data()) { $0.append($1) }
        return try nodeService.eth_call(to: contract, data: invocation)
    }

}
