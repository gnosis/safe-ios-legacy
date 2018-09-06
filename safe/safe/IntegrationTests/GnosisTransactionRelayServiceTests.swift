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

class GnosisTransactionRelayServiceTests: BlockchainIntegrationTest {

    var relayService: GnosisTransactionRelayService!
    let ethService = EthereumKitEthereumService()

    enum Error: String, LocalizedError, Hashable {
        case errorWhileWaitingForCreationTransactionHash
    }

    override func setUp() {
        super.setUp()
        let config = try! AppConfig.loadFromBundle()!
        relayService = GnosisTransactionRelayService(url: config.relayServiceURL, logger: MockLogger())
    }

    func test_safeCreationAndRecovery() throws {
        let deviceKey = encryptionService.generateExternallyOwnedAccount()
        let browserExtensionKey = encryptionService.generateExternallyOwnedAccount()
        let recoveryKey = encryptionService.generateExternallyOwnedAccount()

        let owners = [deviceKey, browserExtensionKey, recoveryKey].map { $0.address }
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

        try transfer(to: safeAddress, amount: response.payment)

        try relayService.startSafeCreation(address: Address(safeAddress))
        let txHash = try waitForSafeCreationTransaction(Address(safeAddress))
        XCTAssertFalse(txHash.value.isEmpty)
        let receipt = try waitForTransaction(txHash)!
        XCTAssertEqual(receipt.status, .success)
    }

    func test_whenGettingGasPrice_thenReturnsIt() throws {
        let response = try relayService.gasPrice()
        let stringInts = [response.fast, response.fastest, response.standard, response.safeLow]
        let ints = stringInts.map { BigInt($0) }
        ints.forEach { XCTAssertNotNil($0, "Repsonse: \(response)") }
    }

    func test_whenEstimatingTransaction_thenReturnsEstimations() throws {
        let safeAddress = Address("0x092CC1854399ADc38Dad4f846E369C40D0a40307")
        let request = EstimateTransactionRequest(safe: safeAddress,
                                                 to: safeAddress,
                                                 value: "1",
                                                 data: "",
                                                 operation: .call)
        let response = try relayService.estimateTransaction(request: request)
        let ints = [response.safeTxGas, response.gasPrice, response.dataGas]
        ints.forEach { XCTAssertNotEqual($0, 0, "Response: \(response)") }
        let address = EthAddress(hex: response.gasToken)
        XCTAssertEqual(address, .zero)
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

}
