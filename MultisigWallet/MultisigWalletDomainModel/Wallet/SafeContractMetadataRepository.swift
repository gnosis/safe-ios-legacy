//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol SafeContractMetadataRepository {

    var multiSendContractAddress: Address { get }
    var proxyFactoryAddress: Address { get }

    func isValidMasterCopy(address: Address) -> Bool
    func isValidProxyFactory(address: Address) -> Bool
    func isValidPaymentRecevier(address: Address) -> Bool

    func version(masterCopyAddress: Address) -> String?
    func deploymentCode(masterCopyAddress: Address) -> Data?
    func EIP712SafeAppTxTypeHash(masterCopyAddress: Address) -> Data?
    func EIP712SafeAppDomainSeparatorTypeHash(masterCopyAddress: Address) -> Data?

}
