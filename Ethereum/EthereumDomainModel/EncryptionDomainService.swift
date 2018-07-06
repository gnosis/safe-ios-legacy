//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public typealias RSVSignature = (r: String, s: String, v: Int)
public typealias EthTransaction = (from: String, value: Int, data: String, gas: String, gasPrice: String, nonce: Int)
public typealias EthRawTransaction =
    (to: String, value: Int, data: String, gas: String, gasPrice: String, nonce: Int)

public protocol EncryptionDomainService {

    func address(browserExtensionCode: String) -> String?
    func contractAddress(from: RSVSignature, for transaction: EthTransaction) throws -> String?
    func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccount
    func randomUInt252() -> String
    func sign(message: String, privateKey: PrivateKey) throws -> RSVSignature
}
