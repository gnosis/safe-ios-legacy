//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class ERC20TokenContractProxy {

    private var nodeService: EthereumNodeDomainService { return DomainRegistry.ethereumNodeService }
    private var encryptionService: EncryptionDomainService { return DomainRegistry.encryptionService }

    public init() {}

    public func balance(of address: Address, contract: Address) throws -> TokenInt {
        let method = encryptionService.hash("balanceOf(address)".data(using: .ascii)!).prefix(4)
        let args = Data(ethHex: address.value).leftPadded(to: 32)
        let data = try nodeService.eth_call(to: contract, data: method + args)
        guard let result = TokenInt(data.toHexString(), radix: 16) else {
            throw NetworkServiceError.serverError
        }
        return result
    }

}
