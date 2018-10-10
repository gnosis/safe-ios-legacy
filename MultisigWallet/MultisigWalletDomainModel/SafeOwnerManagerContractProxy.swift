//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class SafeOwnerManagerContractProxy: EthereumContractProxy {

    private var contract: Address

    public init(_ address: Address) {
        contract = address
    }

    public func getOwners() throws -> [Address] {
        let invocation = method("getOwners()")
        let data = try nodeService.eth_call(to: contract, data: invocation)
        return decodeArrayAddress(data)
    }

}
