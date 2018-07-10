//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public typealias EthTransaction = (from: String, value: Int, data: String, gas: String, gasPrice: String, nonce: Int)
public typealias EthRawTransaction =
    (to: String, value: Int, data: String, gas: String, gasPrice: String, nonce: Int)

public protocol EncryptionDomainService {

    func address(browserExtensionCode: String) -> String?
    func contractAddress(from: EthSignature, for transaction: EthTransaction) throws -> String?
    func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccount
    func ecdsaRandomS() -> String
    func sign(message: String, privateKey: PrivateKey) throws -> EthSignature

}

public struct EthSignature: Codable, Equatable {

    public let r: String
    public let s: String
    public let v: Int

    public init(r: String, s: String, v: Int) {
        self.r = r
        self.s = s
        self.v = v
    }

}
