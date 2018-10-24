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

    private var expected_contractAddress = [(signature: EthSignature, transaction: EthTransaction, address: String?)]()
    private var actual_contractAddress = [(signature: EthSignature, transaction: EthTransaction)]()

    func expect_contractAddress(signature: EthSignature, transaction: EthTransaction, address: String?) {
        expected_contractAddress.append((signature, transaction, address))
    }

    func contractAddress(from: EthSignature, for transaction: EthTransaction) -> String? {
        actual_contractAddress.append((from, transaction))
        return expected_contractAddress[actual_contractAddress.count - 1].address
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
        XCTAssertEqual(actual_hash.map { $0.toHexString() },
                       expected_hash.map { $0.data.toHexString() },
                       file: file,
                       line: line)
    }

    func ethSignature(from signature: Signature) -> EthSignature {
        preconditionFailure()
    }

    func hash(of transaction: Transaction) -> Data {
        preconditionFailure()
    }

    private var expected_hash = [(data: Data, result: Data)]()
    private var actual_hash = [Data]()

    func expect_hash(_ data: Data, result: Data) {
        expected_hash.append((data, result))
    }

    func always_return_hash(_ data: Data) {
        let expectations = (0..<500).map { _ in (Data(), data) }
        expected_hash.append(contentsOf: expectations)
    }

    func hash(_ data: Data) -> Data {
        actual_hash.append(data)
        return expected_hash[actual_hash.count - 1].result
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

    private var expected_addressFrom = [(from: String, result: Address?)]()
    private var actual_addressFrom = [String]()

    func expect_address(from string: String, result: Address?) {
        expected_addressFrom.append((string, result))
    }

    func address(from string: String) -> Address? {
        actual_addressFrom.append(string)
        return expected_addressFrom[actual_addressFrom.count - 1].result
    }

}
