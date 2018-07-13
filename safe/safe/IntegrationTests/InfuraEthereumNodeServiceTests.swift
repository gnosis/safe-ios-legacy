//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import MultisigWalletDomainModel
import MultisigWalletImplementations
import CryptoSwift
import BigInt

class InfuraEthereumNodeServiceTests: XCTestCase {

    let service = InfuraEthereumNodeService()
    let testAddress = Address(value: "0x57b2573E5FA7c7C9B5Fa82F3F03A75F53A0efdF5")
    let emptyAddress = Address(value: "0xd1776c60688a3277c7e69204849989c7dc9f5aaa")
    let notExistingTransactionHash =
        TransactionHash("0xaaaad132ec7112c08c166fbdc7f87a4e17ee00aaaa4c67eb7fde3cab53c60abe")
    let successfulTransactionHash =
        TransactionHash("0x5b448bad86b814dc7aab866f32ffc3d22f140cdcb6c24116548ede8e6e4d343b")
    let failedTransactionHash =
        TransactionHash("0x1b6efea55bb515fd8599d543f57b54ec3ed4242c887269f1a2e9e0008c15ccaf")

    func test_whenAccountNotExists_thenReturnsZero() throws {
        XCTAssertEqual(try service.eth_getBalance(account: emptyAddress), 0)
    }

    func test_whenBalanceCheckedInBackground_thenItIsFetched() throws {
        var balance: BigInt?
        let exp = expectation(description: "wait")
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            balance = try? self.service.eth_getBalance(account: self.testAddress)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(balance, BigInt(30_000_000_000_000_000))
    }

    func test_whenExecutedOnMainThread_thenNotLocked() throws {
        assert(Thread.isMainThread)
        // if the line below doesn't block the main thread, then this test passes. Otherwise, it will lock forever.
        _ = try self.service.eth_getBalance(account: testAddress)
    }

    func test_whenTransactionDoesNotExist_thenReceiptIsNil() throws {
        XCTAssertNil(try service.eth_getTransactionReceipt(transaction: notExistingTransactionHash))
    }

    func test_whenTransactionCompletedSuccess_thenReceiptExists() throws {
        XCTAssertEqual(try service.eth_getTransactionReceipt(transaction: successfulTransactionHash),
                       TransactionReceipt(hash: successfulTransactionHash, status: .success))
    }

    func test_whenTransactionWasDeclined_thenReceiptStatusIsFailed() throws {
        XCTAssertEqual(try service.eth_getTransactionReceipt(transaction: failedTransactionHash),
                       TransactionReceipt(hash: failedTransactionHash, status: .failed))
    }

    func test_whenGettingGasPrice_thenReturnsResult() throws {
        let price = try service.eth_gasPrice()
        XCTAssertGreaterThan(price, 0)
    }

    func test_whenEstimatingGas_thenReturnsResult() throws {
        let tx = TransactionCall(gas: 100, gasPrice: 100, value: 100)
        let gas = try service.eth_estimateGas(transaction: tx)
        XCTAssertGreaterThan(gas, 0)
    }

    func test_whenGettingTransactionCount_thenReturnsResult() throws {
        let address = EthAddress(hex: "0x1CBFf6551B8713296b0604705B1a3B76D238Ae14")
        let nonce = try service.eth_getTransactionCount(address: address, blockNumber: .latest)
        XCTAssertGreaterThan(nonce, 0)
    }

    func test_whenSendingEther_thenSendsIt() throws {
        let sourcePrivateKey =
            PrivateKey(data: Data(hex: "0x72a2a6f44f24b099f279c87548a93fd7229e5927b4f1c7209f7130d5352efa40"))
        let encryptionService = EncryptionService(chainId: .rinkeby)
        let sourceAddress = encryptionService.address(privateKey: sourcePrivateKey)
        let destinationEOA = encryptionService.generateExternallyOwnedAccount()
        let gasPrice = try service.eth_gasPrice()
        let gas = try service.eth_estimateGas(transaction:
            TransactionCall(to: EthAddress(hex: destinationEOA.address.value),
                            gasPrice: EthInt(gasPrice),
                            value: 1))
        let nonce = try service.eth_getTransactionCount(address: EthAddress(hex: sourceAddress.value),
                                                        blockNumber: .latest)
        let tx = EthRawTransaction(to: destinationEOA.address.value,
                                   value: 1,
                                   data: "",
                                   gas: String(gas),
                                   gasPrice: String(gasPrice),
                                   nonce: Int(nonce))
        let rawTx = try encryptionService.sign(transaction: tx, privateKey: sourcePrivateKey)
        let txHash = try service.eth_sendRawTransaction(signedTransactionHash: rawTx)
        let receipt = try waitForTransaction(txHash)!
        XCTAssertEqual(receipt.status, .success)
        let newBalance = try service.eth_getBalance(account: destinationEOA.address)
        XCTAssertEqual(newBalance, BigInt(1))
    }

    func waitForTransaction(_ transactionHash: TransactionHash) throws -> TransactionReceipt? {
        var result: TransactionReceipt? = nil
        let exp = expectation(description: "Transaction Mining")
        try Worker.start(repeating: 3) {
            do {
                guard let receipt = try self.service.eth_getTransactionReceipt(transaction: transactionHash) else {
                    return false
                }
                result = receipt
                exp.fulfill()
                return true
            } catch let error {
                print("Error: \(error)")
                exp.fulfill()
                return true
            }
        }
        waitForExpectations(timeout: 5 * 60)
        return result
    }


}
