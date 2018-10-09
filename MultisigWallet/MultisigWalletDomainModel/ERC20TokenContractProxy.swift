//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
public class ERC20TokenContractProxy: EthereumContractProxy {

    public override init() {}

    public func balance(of address: Address, contract: Address) throws -> TokenInt {
        let args = encodeUInt(BigUInt(Data(ethHex: address.value)))
        let invocation = method("balanceOf(address)") + args
        let data = try nodeService.eth_call(to: contract, data: invocation)
        return TokenInt(decodeUInt(data))
    }

}
