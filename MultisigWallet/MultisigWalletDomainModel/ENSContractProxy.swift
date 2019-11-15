//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class ENSRegistryContractProxy: EthereumContractProxy {

    enum Selectors {
        static let resolver = "resolver(bytes32)"
    }

    public func resolver(node: Data) throws -> Address {
        return try decodeAddress(invoke(Selectors.resolver, encodeFixedBytes(node)))
    }

}

public class ENSResolverContractProxy: EthereumContractProxy {

    public enum Selectors {
        public static let supportsInterface = "supportsInterface(bytes4)"
        public static let address = "addr(bytes32)"
        public static let name = "name(bytes32)"
    }

    public func supportsInterface(_ selector: String) throws -> Bool {
        return try decodeBool(invoke(Selectors.supportsInterface, encodeFixedBytes(method(selector))))
    }

    public func address(node: Data) throws -> Address {
        return try decodeAddress(invoke(Selectors.address, encodeFixedBytes(node)))
    }

    public func name(node: Data) throws -> String? {
        return try decodeString(invoke(Selectors.name, encodeFixedBytes(node)))
    }

}
