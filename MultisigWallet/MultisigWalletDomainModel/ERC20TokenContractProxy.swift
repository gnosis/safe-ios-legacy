//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class ERC20TokenContractProxy: EthereumContractProxy {

    public func balance(of address: Address) throws -> TokenInt {
        return try TokenInt(decodeUInt(invoke("balanceOf(address)", encodeAddress(address))))
    }

}
