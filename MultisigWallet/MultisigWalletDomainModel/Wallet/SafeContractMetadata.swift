//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct SafeContractMetadata: Equatable {

    public var multiSendContractAddress: Address
    public var proxyFactoryAddress: Address
    public var safeFunderAddress: Address
    public var metadata: [MasterCopyMetadata]

    public init(multiSendContractAddress: Address,
                proxyFactoryAddress: Address,
                safeFunderAddress: Address,
                metadata: [MasterCopyMetadata]) {
        self.multiSendContractAddress = multiSendContractAddress
        self.proxyFactoryAddress = proxyFactoryAddress
        self.safeFunderAddress = safeFunderAddress
        self.metadata = metadata
    }
}

public struct MasterCopyMetadata: Equatable {

    public var address: Address
    public var version: String
    public var txTypeHash: Data
    public var domainSeparatorHash: Data
    public var proxyCode: Data

    public init(address: Address,
                version: String,
                txTypeHash: Data,
                domainSeparatorHash: Data,
                proxyCode: Data) {
        self.address = address
        self.version = version
        self.txTypeHash = txTypeHash
        self.domainSeparatorHash = domainSeparatorHash
        self.proxyCode = proxyCode
    }

}
