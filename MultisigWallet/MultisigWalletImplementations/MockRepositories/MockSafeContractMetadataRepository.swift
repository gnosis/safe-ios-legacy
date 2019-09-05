//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class MockSafeContractMetadataRepository: SafeContractMetadataRepository {

    public var multiSendContractAddress: Address
    public var proxyFactoryAddress: Address
    public var latestMasterCopyAddress: Address

    public init() {
        multiSendContractAddress = Address("0x0000000000000000000000000000000000000001")
        proxyFactoryAddress = Address("0x0000000000000000000000000000000000000002")
        latestMasterCopyAddress = Address("0x0000000000000000000000000000000000000003")
    }

    public var isOldMasterCopy_result: Bool = false

    public func isOldMasterCopy(address: Address) -> Bool {
        return isOldMasterCopy_result
    }

    public func isValidMasterCopy(address: Address) -> Bool {
        return false
    }

    public func isValidProxyFactory(address: Address) -> Bool {
        return false
    }

    public func isValidPaymentRecevier(address: Address) -> Bool {
        return false
    }

    public func version(masterCopyAddress: Address) -> String? {
        return nil
    }

    public var contractVersion = ""
    public func latestContractVersion() -> String {
        return contractVersion
    }

    public func deploymentCode(masterCopyAddress: Address) -> Data? {
        return nil
    }

    public func EIP712SafeAppTxTypeHash(masterCopyAddress: Address) -> Data? {
        return nil
    }

    public func EIP712SafeAppDomainSeparatorTypeHash(masterCopyAddress: Address) -> Data? {
        return nil
    }

}
