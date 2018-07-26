//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public typealias EthTransaction = (from: String, value: Int, data: String, gas: String, gasPrice: String, nonce: Int)
public typealias EthRawTransaction =
    (to: String, value: Int, data: String, gas: String, gasPrice: String, nonce: Int)

public protocol EncryptionDomainService {

    func address(browserExtensionCode: String) -> String?
    func contractAddress(from: EthSignature, for transaction: EthTransaction) -> String?
    func generateExternallyOwnedAccount() -> ExternallyOwnedAccount
    func ecdsaRandomS() -> BigUInt
    func sign(message: String, privateKey: PrivateKey) -> EthSignature
    func hash(of transaction: Transaction) -> Data
    func address(hash: Data, signature: EthSignature) -> String?
    func data(from signature: EthSignature) -> Data
    func sign(transaction: Transaction, privateKey: PrivateKey) -> Data

}

public struct EthSignature: Codable, Equatable {

    public var r: String
    public var s: String
    public var v: Int

    public init(r: String, s: String, v: Int) {
        self.r = r
        self.s = s
        self.v = v
    }

}
