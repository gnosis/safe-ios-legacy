//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

@testable import safe
import XCTest
import MultisigWalletDomainModel
import MultisigWalletImplementations
import BigInt
import Common
import CryptoSwift

class BlockchainIntegrationTest: XCTestCase {

    var infuraService: InfuraEthereumNodeService!
    var encryptionService: EncryptionService!
    var config: AppConfig!

    override func setUp() {
        super.setUp()
        config = try! AppConfig.loadFromBundle()!
        infuraService = InfuraEthereumNodeService(url: config.nodeServiceConfig.url,
                                                  chainId: config.nodeServiceConfig.chainId)
        encryptionService = EncryptionService(chainId: EIP155ChainId(rawValue: config.encryptionServiceChainId)!)
    }

    func waitForTransaction(_ transactionHash: TransactionHash) throws -> TransactionReceipt? {
        var result: TransactionReceipt?
        let exp = expectation(description: "Transaction Mining")
        Worker.start(repeating: 3) {
            do {
                guard let receipt =
                    try self.infuraService.eth_getTransactionReceipt(transaction: transactionHash) else {
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

    func transfer(to address: String, amount: String) throws {
        // TODO: take this key from App Config
        let sourcePrivateKey =
            PrivateKey(data: Data(ethHex: "0x72a2a6f44f24b099f279c87548a93fd7229e5927b4f1c7209f7130d5352efa40"))
        let encryptionService = EncryptionService(chainId: .rinkeby)
        let sourceAddress = encryptionService.address(privateKey: sourcePrivateKey)
        let destination = MultisigWalletDomainModel.Address(address)
        let value = EthInt(BigInt(amount)!)
        let gasPrice = try infuraService.eth_gasPrice()
        let gas = try infuraService.eth_estimateGas(transaction: TransactionCall(to: EthAddress(hex: destination.value),
                                                                                 gasPrice: EthInt(gasPrice),
                                                                                 value: value))
        let nonce = try infuraService.eth_getTransactionCount(address: EthAddress(hex: sourceAddress.value),
                                                              blockNumber: .latest)
        let tx = EthRawTransaction(to: destination.value,
                                   value: Int(value.value),
                                   data: "",
                                   gas: String(gas),
                                   gasPrice: String(gasPrice),
                                   nonce: Int(nonce))
        let rawTx = try encryptionService.sign(transaction: tx, privateKey: sourcePrivateKey)
        let txHash = try infuraService.eth_sendRawTransaction(rawTransaction: rawTx)
        let receipt = try waitForTransaction(txHash)!
        XCTAssertEqual(receipt.status, .success)
        let newBalance = try infuraService.eth_getBalance(account: destination)
        XCTAssertEqual(newBalance, BigInt(value.value))
    }

}
