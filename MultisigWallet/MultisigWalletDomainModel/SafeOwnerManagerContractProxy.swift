//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

// swiftlint:disable:next line_length
// see https://github.com/gnosis/safe-contracts/blob/6db7ce0f600d391bc6f34b144d7845bf5f227d81/contracts/base/ModuleManager.sol#L11
public class SafeOwnerManagerContractProxy: EthereumContractProxy {

    public static let sentinelAddress = Address("0x" + Data([0x1]).leftPadded(to: 20).toHexString())

    public func getOwners() throws -> [Address] {
        return try decodeArrayAddress(invoke("getOwners()"))
    }

    public func previousOwner(to owner: Address) throws -> Address? {
        let owners = try getOwners()
        guard let index = owners.firstIndex(where: { $0.value.lowercased() == owner.value.lowercased() }) else {
            return nil
        }
        return index > 0 ? owners[index - 1] : SafeOwnerManagerContractProxy.sentinelAddress
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

    public func changeThreshold(_ newValue: Int) -> Data {
        return invocation("changeThreshold(uint256)", encodeUInt(BigUInt(newValue)))
    }

    public func swapOwner(prevOwner: Address, old: Address, new: Address) -> Data {
        return invocation("swapOwner(address,address,address)",
                          encodeAddress(prevOwner),
                          encodeAddress(old),
                          encodeAddress(new))
    }

    public func decodeSwapOwnerArguments(from data: Data) -> (prevOwner: Address, old: Address, new: Address)? {
        let argumentLength = 32
        let selector = self.method("swapOwner(address,address,address)")
        guard data.count == selector.count + 3 * argumentLength &&
            data.prefix(selector.count) == selector else { return nil }
        var input = data
        input.removeFirst(selector.count)
        let prevOwner = decodeAddress(input)
        input.removeFirst(argumentLength)
        let old = decodeAddress(input)
        input.removeFirst(argumentLength)
        let new = decodeAddress(input)
        return (prevOwner, old, new)
    }

    public func removeOwner(prevOwner: Address, owner: Address, newThreshold threshold: Int) -> Data {
        return invocation("removeOwner(address,address,uint256)",
                          encodeAddress(prevOwner),
                          encodeAddress(owner),
                          encodeUInt(BigUInt(threshold)))
    }

}
