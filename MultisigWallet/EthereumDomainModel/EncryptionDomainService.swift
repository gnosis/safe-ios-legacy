//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

// TODO: merge
public typealias EthRSVSignature = (r: String, s: String, v: Int)
public typealias EthTransaction = (from: String, value: Int, data: String, gas: String, gasPrice: String, nonce: Int)
public typealias EthRawTransaction =
    (to: String, value: Int, data: String, gas: String, gasPrice: String, nonce: Int)

public protocol EncryptionDomainService {

    func address(browserExtensionCode: String) -> String?
    func contractAddress(from: EthRSVSignature, for transaction: EthTransaction) throws -> String?
    func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccount
    func ecdsaRandomS() -> String
    func sign(message: String, privateKey: PrivateKey) throws -> EthRSVSignature
}
