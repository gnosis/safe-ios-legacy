//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import BigInt

class MockEncryptionService1: EncryptionDomainService {

    func generateExternallyOwnedAccount() -> ExternallyOwnedAccount {
        preconditionFailure()
    }

    func address(browserExtensionCode: String) -> String? {
        preconditionFailure()
    }

    func contractAddress(from: EthSignature, for transaction: EthTransaction) -> String? {
        preconditionFailure()
    }

    func ecdsaRandomS() -> BigUInt {
        return 3
    }

    private var expected_sign = [(message: String, privateKey: PrivateKey, signature: EthSignature)]()
    private var actual_sign = [(message: String, privateKey: PrivateKey)]()

    func expect_sign(message: String, privateKey: PrivateKey, signature: EthSignature) {
        expected_sign.append((message, privateKey, signature))
    }

    func sign(message: String, privateKey: PrivateKey) -> EthSignature {
        actual_sign.append((message, privateKey))
        return expected_sign[actual_sign.count - 1].signature
    }

    func verify(line: UInt = #line, file: StaticString = #file) {
        XCTAssertEqual(
            actual_sign.map { "message: \($0.message), privateKey: \($0.privateKey.data.base64EncodedString())" },
            expected_sign.map { "message: \($0.message), privateKey: \($0.privateKey.data.base64EncodedString())" },
            file: file,
            line: line)
    }

    func ethSignature(from signature: Signature) -> EthSignature {
        preconditionFailure()
    }

    func hash(of transaction: Transaction) -> Data {
        preconditionFailure()
    }

    func hash(_ data: Data) -> Data {
        preconditionFailure()
    }

    func address(hash: Data, signature: EthSignature) -> String? {
        preconditionFailure()
    }

    func data(from signature: EthSignature) -> Data {
        preconditionFailure()
    }

    func sign(transaction: Transaction, privateKey: PrivateKey) -> Data {
        preconditionFailure()
    }

    func address(from string: String) -> Address? {
        preconditionFailure()
    }

}
