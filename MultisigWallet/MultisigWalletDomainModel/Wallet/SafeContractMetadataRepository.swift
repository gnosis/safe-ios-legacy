//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol SafeContractMetadataRepository {

    var proxyFactoryAddress: Address { get }

    var latestMasterCopyAddress: Address { get }
    func isValidMasterCopy(address: Address) -> Bool
    func isOldMasterCopy(address: Address) -> Bool
    func version(masterCopyAddress: Address) -> String?

    func isValidProxyFactory(address: Address) -> Bool
    func isValidPaymentRecevier(address: Address) -> Bool

    func deploymentCode(masterCopyAddress: Address) -> Data?
    func EIP712SafeAppTxTypeHash(masterCopyAddress: Address) -> Data?
    func EIP712SafeAppDomainSeparatorTypeHash(masterCopyAddress: Address) -> Data?

    /// Default multi send contract address
    var multiSendContractAddress: Address { get }
    func version(multiSendAddress: Address) -> Int?
//    func isValidMultiSend(address: Address) -> Bool

}
