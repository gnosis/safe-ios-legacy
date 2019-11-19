//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import EthereumKit

public enum ENSAPIServiceError: LocalizedError {
    case resolverNotFound
    case addressResolutionNotSupported
    case addressNotFound
    case resolvedNameNotMatchingOriginalAddress

    public var errorDescription: String? {
        switch self {
        case .resolverNotFound:
            return LocalizedString("ios_error_ens_resolver_not_found", comment: "No resolver set for the record")
        case .addressResolutionNotSupported:
            return LocalizedString("ios_error_ens_not_supported", comment: "Resolution not supported")
        case .addressNotFound:
            return LocalizedString("ios_error_ens_address_not_found", comment: "Address not found in the resolver")
        case .resolvedNameNotMatchingOriginalAddress:
            return LocalizedString("ios_error_ens_unauthentic_reverse_name",
                                   comment: "Resolved to the name which is not resolving to the address")
        }
    }

}

public final class ENSAPIService: ENSDomainService {

    public let registryAddress: MultisigWalletDomainModel.Address

    public init(registryAddress: MultisigWalletDomainModel.Address) {
        self.registryAddress = registryAddress
    }

    public func address(for name: String) throws -> MultisigWalletDomainModel.Address {
        let normalizedName = try IDN.utf8ToASCII(name, useSTD3ASCIIRules: true)
        let node = namehash(normalizedName)

        // get resolver
        let registryContract = ENSRegistryContractProxy(registryAddress)
        let resolverAddress = try registryContract.resolver(node: node)
        if resolverAddress.isZero {
            throw ENSAPIServiceError.resolverNotFound
        }

        // resolve address
        let resolverContract = ENSResolverContractProxy(resolverAddress)
        let isResolvingSupported = try resolverContract.supportsInterface(ENSResolverContractProxy.Selectors.address)
        guard isResolvingSupported else {
            throw ENSAPIServiceError.addressResolutionNotSupported
        }
        let resolvedAddress = try resolverContract.address(node: node)
        if resolvedAddress.isZero {
            throw ENSAPIServiceError.addressNotFound
        }
        return DomainRegistry.encryptionService.address(from: resolvedAddress.value)!
    }

    public func name(for address: MultisigWalletDomainModel.Address) throws -> String? {
        // construct a reverse node
        let addressString = Data(ethHex: address.value).toHexString()
        let reverseName = addressString + ".addr.reverse"
        let normalizedName = try IDN.utf8ToASCII(reverseName, useSTD3ASCIIRules: true)
        let node = namehash(normalizedName)

        // get resolver
        let registryContract = ENSRegistryContractProxy(registryAddress)
        let resolverAddress = try registryContract.resolver(node: node)
        if resolverAddress.isZero {
            throw ENSAPIServiceError.resolverNotFound
        }

        let reverseResolverContract = ENSReverseResolverContractProxy(resolverAddress)
        // resolve the name
        guard let resolvedASCIIName = try reverseResolverContract.name(node: node) else {
            return nil
        }
        let resolvedName = try IDN.asciiToUTF8(resolvedASCIIName)
        let resolvedAddress = try self.address(for: resolvedName)
        guard address.value.caseInsensitiveCompare(resolvedAddress.value) == .orderedSame else {
            throw ENSAPIServiceError.resolvedNameNotMatchingOriginalAddress
        }
        return resolvedName
    }

    typealias Node = Data

    func namehash(_ name: String) -> Node {
        // domain is expected to be IDN-normalized and UTS46 converted
        if name.isEmpty {
            return Data(repeating: 0, count: 32)
        } else {
            let parts = name.split(separator: ".", maxSplits: 1)
            let label = parts.count > 0 ? String(parts.first!) : ""
            let remainder = parts.count > 1 ? String(parts.last!) : ""
            return sha3(namehash(remainder) + sha3(label))
        }
    }

    private func sha3(_ string: String) -> Data {
        return sha3(string.data(using: .utf8)!)
    }

    private func sha3(_ data: Data) -> Data {
        return Crypto.hashSHA3_256(data)
    }

}
