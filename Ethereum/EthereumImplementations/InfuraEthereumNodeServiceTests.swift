//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import EthereumDomainModel

class InfuraEthereumNodeServiceTests: XCTestCase {

    let service = InfuraEthereumNodeService()
    let testAddress = Address(value: "0x57b2573E5FA7c7C9B5Fa82F3F03A75F53A0efdF5")
    let emptyAddress = Address(value: "0xd1776c60688a3277c7e69204849989c7dc9f5aaa")

    func test_whenAccountNotExists_thenReturnsZero() throws {
        XCTAssertEqual(try service.eth_getBalance(account: emptyAddress), Ether.zero)
    }

    func test_whenAccountHasFunds_thenBalanceReturned() throws {
        var balance: Ether?
        let exp = expectation(description: "wait")
        DispatchQueue.global().async {
            balance = try? self.service.eth_getBalance(account: self.testAddress)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(balance, Ether(amount: 30_000_000_000_000_000))
    }

    func test_whenExecutedOnMainThread_thenNotLocked() throws {
        assert(Thread.isMainThread)
        _ = try self.service.eth_getBalance(account: testAddress)
    }

}
