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

    public func transfer(to recipient: Address, amount: TokenInt) -> Data {
        return invocation("transfer(address,uint256)", encodeAddress(recipient), encodeUInt(BigUInt(amount)))
    }

}
