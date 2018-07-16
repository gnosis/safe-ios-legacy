//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import MultisigWalletDomainModel
import MultisigWalletImplementations
import BigInt
import Common
import CryptoSwift

class GnosisTransactionRelayServiceTests: XCTestCase {

    let relayService = GnosisTransactionRelayService()
    let ethService = EthereumKitEthereumService()
    lazy var encryptionService = EncryptionService(chainId: .any, ethereumService: ethService)
    let infuraService = InfuraEthereumNodeService()

    enum Error: String, LocalizedError, Hashable {
        case errorWhileWaitingForCreationTransactionHash
    }

    func test_safeCreation() throws {
        let eoa1 = encryptionService.generateExternallyOwnedAccount()
        let eoa2 = encryptionService.generateExternallyOwnedAccount()
        let eoa3 = encryptionService.generateExternallyOwnedAccount()
        let owners = [eoa1, eoa2, eoa3].map { $0.address }
        let ecdsaRandomS = encryptionService.ecdsaRandomS()
        let request = SafeCreationTransactionRequest(owners: owners, confirmationCount: 2, ecdsaRandomS: ecdsaRandomS)
        let response = try relayService.createSafeCreationTransaction(request: request)

        XCTAssertEqual(response.signature.s, request.s)
        let signature = EthSignature(r: response.signature.r,
                                     s: response.signature.s,
                                     v: Int(response.signature.v) ?? 0)
        let transaction = (response.tx.from,
                           response.tx.value,
                           response.tx.data,
                           response.tx.gas,
                           response.tx.gasPrice,
                           response.tx.nonce)
        guard let safeAddress = encryptionService.contractAddress(from: signature, for: transaction) else {
            XCTFail("Can't extract safe address from server response")
            return
        }
        XCTAssertEqual(safeAddress, response.safe)

        try fundSafe(address: safeAddress, amount: response.payment)

        try relayService.startSafeCreation(address: Address(safeAddress))
        let txHash = try waitForSafeCreationTransaction(Address(safeAddress))
        XCTAssertFalse(txHash.value.isEmpty)
        let receipt = try waitForTransaction(txHash)!
        XCTAssertEqual(receipt.status, .success)
    }

    // TODO: remove code duplication
    func fundSafe(address: String, amount: String) throws {
        let sourcePrivateKey =
            PrivateKey(data: Data(hex: "0x72a2a6f44f24b099f279c87548a93fd7229e5927b4f1c7209f7130d5352efa40"))
        let encryptionService = EncryptionService(chainId: .rinkeby)
        let sourceAddress = encryptionService.address(privateKey: sourcePrivateKey)
        let destination = MultisigWalletDomainModel.Address(address)
        let value = EthInt(BigInt(amount)!)

        let gasPrice = try infuraService.eth_gasPrice()
        let gas = try infuraService.eth_estimateGas(transaction:
            TransactionCall(to: EthAddress(hex: destination.value),
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

    func waitForSafeCreationTransaction(_ address: Address) throws -> TransactionHash {
        var result: TransactionHash!
        let exp = expectation(description: "Safe creation")
        Worker.start(repeating: 5) {
            do {
                guard let hash = try self.relayService.safeCreationTransactionHash(address: address) else {
                    return false
                }
                result = hash
                exp.fulfill()
                return true
            } catch let error {
                print("Error: \(error)")
                exp.fulfill()
                return true
            }
        }
        waitForExpectations(timeout: 5 * 60)
        guard let hash = result else { throw Error.errorWhileWaitingForCreationTransactionHash }
        return hash
    }

    func waitForTransaction(_ transactionHash: TransactionHash) throws -> TransactionReceipt? {
        var result: TransactionReceipt? = nil
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


}
