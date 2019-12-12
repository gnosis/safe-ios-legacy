//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class InMemorySafeContractMetadataRepository: SafeContractMetadataRepository {

    private let metadata: SafeContractMetadata

    public init(metadata: SafeContractMetadata) {
        self.metadata = metadata
    }

    public var multiSendContractAddress: Address {
        return metadata.multiSendContractAddress
    }

    public var proxyFactoryAddress: Address {
        return metadata.proxyFactoryAddress
    }

    public var fallbackHandlerAddress: Address {
        return metadata.defaultFallbackHandlerAddress
    }

    public var latestMasterCopyAddress: Address {
        precondition(!metadata.metadata.isEmpty, "Metadata is empty")
        return metadata.metadata.last!.address
    }

    public func isOldMasterCopy(address: Address) -> Bool {
        return metadata.metadata.dropLast().contains { $0.address.value.lowercased() == address.value.lowercased() }
    }

    public func isValidMasterCopy(address: Address) -> Bool {
        return metadata.metadata.contains { $0.address.value.lowercased() == address.value.lowercased() }
    }

    public func isValidProxyFactory(address: Address) -> Bool {
        return proxyFactoryAddress.value.lowercased() == address.value.lowercased()
    }

    public func isValidPaymentRecevier(address: Address) -> Bool {
        return metadata.safeFunderAddress.value.lowercased() == address.value.lowercased() || address.isZero
    }

    public func version(masterCopyAddress: Address) -> String? {
        return self[masterCopyAddress]?.version
    }

    public func deploymentCode(masterCopyAddress: Address) -> Data {
        let contract = EthereumContractProxy()
        return metadata.proxyCode + contract.encodeAddress(masterCopyAddress)
    }

    public func EIP712SafeAppTxTypeHash(masterCopyAddress: Address) -> Data? {
        return self[masterCopyAddress]?.txTypeHash
    }

    public func EIP712SafeAppDomainSeparatorTypeHash(masterCopyAddress: Address) -> Data? {
        return self[masterCopyAddress]?.domainSeparatorHash
    }

    private subscript(_ address: Address) -> MasterCopyMetadata? {
        return metadata.metadata.first { $0.address.value.lowercased() == address.value.lowercased() }
    }

}
