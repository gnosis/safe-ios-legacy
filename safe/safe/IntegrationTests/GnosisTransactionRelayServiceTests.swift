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
        let (_, _) = try createNewSafe()
    }

    private func createNewSafe() throws -> (address: Address, recoveryKey: ExternallyOwnedAccount)! {
        let deviceKey = encryptionService.generateExternallyOwnedAccount()
        let browserExtensionKey = encryptionService.generateExternallyOwnedAccount()
        let recoveryKey = encryptionService.generateExternallyOwnedAccount()
        let derivedKeyFromRecovery = encryptionService.deriveExternallyOwnedAccountFrom(
            mnemonic: recoveryKey.mnemonic.words, at: 1)

        let owners = [deviceKey, browserExtensionKey, recoveryKey, derivedKeyFromRecovery].map { $0.address }
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
            return nil
        }
        XCTAssertEqual(safeAddress, response.safe)

        try transfer(to: safeAddress, amount: response.payment)

        try relayService.startSafeCreation(address: Address(safeAddress))
        let txHash = try waitForSafeCreationTransaction(Address(safeAddress))
        XCTAssertFalse(txHash.value.isEmpty)
        let receipt = try waitForTransaction(txHash)!
        XCTAssertEqual(receipt.status, .success)
        return (Address(safeAddress), recoveryKey)
    }

    func test_recoveryOnly() {
        let address = Address("0xE2BC19Be4cDEf0D68D82c0C86E97234708Cf6c07")
        let mnemonic = ["tiger", "over", "fabric", "diary", "subway", "quick", "sheriff", "team", "step", "develop", "wife", "afford"]
        recoverSafe(address, mnemonic)
    }

    private func recoverSafe(_ safeAddress: Address, _ mnemonic: [String]) {
        let recoveryKey = encryptionService.deriveExternallyOwnedAccountFrom(
            mnemonic: mnemonic, at: 0)
        let derivedKeyFromRecovery = encryptionService.deriveExternallyOwnedAccountFrom(
            mnemonic: mnemonic, at: 1)

        // Get Safe info and assure that 2 keys are among owners


        // Generate 2 new owners
        // Form Transaction
        // Get Fee Estimate and update transaction
        // Fund safe with missing amount of Ether
        // Form Signatures for a transaction
        // Form SubmitTransactionRequest(transaction, signatures)
        // DomainRegistry.transactionRelayService.submitTransaction(request: request)
        // Monitor transaction
        // Get safe info and assure that new safe owners are there

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
