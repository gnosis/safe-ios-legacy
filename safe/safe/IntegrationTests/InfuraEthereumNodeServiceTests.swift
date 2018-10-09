//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import MultisigWalletDomainModel
import MultisigWalletImplementations
import CryptoSwift
import BigInt

class InfuraEthereumNodeServiceTests: BlockchainIntegrationTest {

    var service: InfuraEthereumNodeService!
    let testAddress = Address("0x57b2573E5FA7c7C9B5Fa82F3F03A75F53A0efdF5")
    let emptyAddress = Address("0xd1776c60688a3277c7e69204849989c7dc9f5aaa")
    let notExistingTransactionHash =
        TransactionHash("0xaaaad132ec7112c08c166fbdc7f87a4e17ee00aaaa4c67eb7fde3cab53c60abe")
    let successfulTransactionHash =
        TransactionHash("0x5b448bad86b814dc7aab866f32ffc3d22f140cdcb6c24116548ede8e6e4d343b")
    let failedTransactionHash =
        TransactionHash("0x1b6efea55bb515fd8599d543f57b54ec3ed4242c887269f1a2e9e0008c15ccaf")

    override func setUp() {
        super.setUp()
        let config = try! AppConfig.loadFromBundle()!
        service = InfuraEthereumNodeService(url: config.nodeServiceConfig.url,
                                            chainId: config.nodeServiceConfig.chainId)
    }

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
        let destinationEOA = encryptionService.generateExternallyOwnedAccount()
        try transfer(to: destinationEOA.address.value, amount: "1")
    }

    func test_nonceFromSafeContract() throws {
        let encryptionService = EncryptionService(chainId: .rinkeby)
        let functionSignature = "nonce()"
        let methodID = encryptionService.hash(functionSignature.data(using: .ascii)!).prefix(4)
        let call = TransactionCall(to: EthAddress(hex: "0x092CC1854399ADc38Dad4f846E369C40D0a40307"),
                                   data: EthData(methodID))
        let resultData = try service.eth_call(transaction: call, blockNumber: .latest)
        let nonce = BigInt(hex: resultData.toHexString())!
        XCTAssertEqual(nonce, 0)
    }

    func test_balanceFromERC20Contract() throws {
        DomainRegistry.put(service: service, for: EthereumNodeDomainService.self)
        let proxy = ERC20TokenContractProxy()
        let balance = try proxy.balance(of: Address("0x0ddc793680ff4f5793849c8c6992be1695cbe72a"),
                                        contract: Address("0x36276f1f2cb8e9c11c508aad00556f819c5ad876"))
        XCTAssertEqual(balance, TokenInt("20000000000000000000000"))
    }

    func test_safe_getOwners() throws {
        DomainRegistry.put(service: service, for: EthereumNodeDomainService.self)
        let proxy = SafeOwnerManagerContractProxy(Address("0x092CC1854399ADc38Dad4f846E369C40D0a40307"))
        let expected = ["0xd06ab3c0d8094791f8f3bdb6b66cb82a68b6d846",
                        "0xb952005d631d4892430144a2d5850b1cd0efc981",
                        "0x41b152984f80c4017d3640662727c263e2073780"].map { Address($0) }
        let owners = try proxy.getOwners()
        print(owners)
        XCTAssertEqual(owners, expected)
    }

}
