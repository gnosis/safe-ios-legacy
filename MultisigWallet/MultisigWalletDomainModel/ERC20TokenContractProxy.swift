//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

// see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
public class ERC20TokenContractProxy: EthereumContractProxy {

    public func balance(of address: Address) throws -> TokenInt {
        return try TokenInt(decodeUInt(invoke("balanceOf(address)", encodeAddress(address))))
    }

    private let transferMethodSignature = "transfer(address,uint256)"

    public func transfer(to recipient: Address, amount: TokenInt) -> Data {
        return invocation(transferMethodSignature, encodeAddress(recipient), encodeUInt(BigUInt(amount)))
    }

    public func decodedTransfer(from data: Data) -> (recipient: Address, amount: TokenInt)? {
        let head = invocation(transferMethodSignature)
        guard data.prefix(head.count) == head else { return nil }
        var argumentsData = data.suffix(from: head.count)
        let recipient = decodeAddress(argumentsData)
        argumentsData.removeFirst(32)
        let amount = decodeUInt(argumentsData)
        argumentsData.removeFirst(32)
        guard argumentsData.isEmpty else { return nil }
        return (recipient, TokenInt(amount))
    }

}
