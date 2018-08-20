//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import BigInt

class MockEthereumNodeService1: EthereumNodeDomainService {

    private var expected_eth_getBalance = [(account: Address, balance: BigInt)]()
    private var actual_eth_getBalance = [Address]()
    private var eth_getBalance_throws_error: Error?

    func expect_eth_getBalance(account: Address, balance: BigInt) {
        expected_eth_getBalance.append((account, balance))
    }

    func expect_eth_getBalance_throw(_ error: Error) {
        eth_getBalance_throws_error = error
    }

    func eth_getBalance(account: Address) throws -> BigInt {
        actual_eth_getBalance.append(account)
        if let error = eth_getBalance_throws_error {
            throw error
        }
        return expected_eth_getBalance[actual_eth_getBalance.count - 1].balance
    }

    func verify(line: UInt = #line) {
        XCTAssertEqual(actual_eth_getBalance.map { $0.value },
                       expected_eth_getBalance.map { $0.account.value },
                       line: line)
        XCTAssertEqual(actual_eth_getTransactionReceipt.map { $0.value },
                       expected_eth_getTransactionReceipt.map { $0.hash.value },
                       line: line)
    }

    private var expected_eth_getTransactionReceipt = [(hash: TransactionHash, receipt: TransactionReceipt?)]()
    private var actual_eth_getTransactionReceipt = [(TransactionHash)]()
    private var eth_getTransactionReceipt_throws_error: Error?

    func expect_eth_getTransactionReceipt(transaction: TransactionHash, receipt: TransactionReceipt?) {
        expected_eth_getTransactionReceipt.append((transaction, receipt))
    }

    func expect_eth_getTransactionReceipt_throw(_ error: Error) {
        eth_getTransactionReceipt_throws_error = error
    }

    func eth_getTransactionReceipt(transaction: TransactionHash) throws -> TransactionReceipt? {
        actual_eth_getTransactionReceipt.append(transaction)
        if let error = eth_getTransactionReceipt_throws_error {
            throw error
        }
        return expected_eth_getTransactionReceipt[actual_eth_getTransactionReceipt.count - 1].receipt
    }

    func eth_call(to: Address, data: Data) throws -> Data {
        return Data()
    }

}
