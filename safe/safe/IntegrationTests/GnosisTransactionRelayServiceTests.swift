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

    func test_whenAddingOwner_thenNewOwnerExists() throws {
        let fundingEOA = provisionFundingAccount()
        var owners = createEOA(count: 3)
        let safe = try prepareSafeCreation(owners)
        try pay(from: fundingEOA, to: safe.address, amount: safe.creationFee)
        try safe.deploy()
        owners.append(contentsOf: createEOA())
        let addOwnerTx = try safe.prepareAddOwnerTx(owners.last!, threshold: owners.count - 1)
        owners[0..<2].forEach { safe.sign(addOwnerTx, by: $0) }
        try pay(from: fundingEOA, to: safe.address, amount: addOwnerTx.fee!.amount * 2) // TODO: fee is too high
        try safe.executeTransaction(addOwnerTx)
        let newOwners = try SafeOwnerManagerContractProxy(safe.address).getOwners()
        XCTAssertTrue(newOwners.contains { $0.value.lowercased() == owners.last!.address.value.lowercased() })
        XCTAssertTrue(try safe.isOwner(owners.last!.address))
        XCTAssertEqual(try safe.getThreshold(), owners.count - 1)
    }

    func provisionFundingAccount() -> ExternallyOwnedAccount {
        let privateKey =
            PrivateKey(data: Data(ethHex: "0x72a2a6f44f24b099f279c87548a93fd7229e5927b4f1c7209f7130d5352efa40"))
        let publicKey = PublicKey(data: ethService.createPublicKey(privateKey: privateKey.data))
        return ExternallyOwnedAccount(address: encryptionService.address(privateKey: privateKey),
                                      mnemonic: Mnemonic(words: []),
                                      privateKey: privateKey,
                                      publicKey: publicKey)
    }

    func createEOA(count: Int = 1) -> [ExternallyOwnedAccount] {
        return (0..<count).map { _ in encryptionService.generateExternallyOwnedAccount() }
    }

    func prepareSafeCreation(_ owners: [ExternallyOwnedAccount]) throws -> Safe {
        let ecdsaRandomS = encryptionService.ecdsaRandomS()
        let request = SafeCreationTransactionRequest(owners: owners.map { $0.address },
                                                     confirmationCount: 2,
                                                     ecdsaRandomS: ecdsaRandomS)
        let response = try relayService.createSafeCreationTransaction(request: request)
        var safe = Safe()
        safe._test = self
        safe.address = response.walletAddress
        safe.creationFee = response.deploymentFee
        return safe
    }

    func pay(from sender: ExternallyOwnedAccount, to recipient: Address, amount: TokenInt) throws {
        let gasPrice = try infuraService.eth_gasPrice()
        let callTx = TransactionCall(sender: sender.address, recipient: recipient, gasPrice: gasPrice, amount: amount)
        let gas = try infuraService.eth_estimateGas(transaction: callTx)
        let nonce = try infuraService.eth_getTransactionCount(address: callTx.from!, blockNumber: .latest)
        let tx = ethRawTx(callTx: callTx, gas: gas, nonce: nonce)
        let rawTx = try encryptionService.sign(transaction: tx, privateKey: sender.privateKey)
        let txHash = try infuraService.eth_sendRawTransaction(rawTransaction: rawTx)
        let receipt = try waitForTransaction(txHash)!
        assert(receipt.status == .success)
    }

    func ethRawTx(callTx: TransactionCall, gas: BigInt, nonce: BigInt) -> EthRawTransaction {
        return EthRawTransaction(to: callTx.to!.hexString,
                                 value: Int(callTx.value!.value),
                                 data: callTx.data?.hexString ?? "",
                                 gas: String(gas),
                                 gasPrice: String(callTx.gasPrice!.value),
                                 nonce: Int(nonce))
    }

}

struct Safe {

    var creationFee: TokenInt!
    var address: Address!

    var _test: GnosisTransactionRelayServiceTests!

    func prepareAddOwnerTx(_ owner: ExternallyOwnedAccount, threshold: Int) throws -> Transaction {
        let proxy = SafeOwnerManagerContractProxy(address)
        let data = proxy.addOwner(owner.address, newThreshold: threshold)
        let request = EstimateTransactionRequest(safe: address,
                                                 to: address,
                                                 value: String(0),
                                                 data: data.toHexString(),
                                                 operation: .call)
        let response = try _test.relayService.estimateTransaction(request: request)
        let fee = BigInt(response.gasPrice) * (BigInt(response.dataGas) + BigInt(response.safeTxGas))
        let nonce = try proxy.nonce()
        let tx = Transaction(id: TransactionID(),
                             type: .transfer,
                             walletID: WalletID(),
                             accountID: AccountID(tokenID: Token.Ether.id,
                                                  walletID: WalletID()))
        tx.change(sender: address)
            .change(feeEstimate: TransactionFeeEstimate(gas: response.safeTxGas,
                                                        dataGas: response.dataGas,
                                                        gasPrice: TokenAmount(amount: TokenInt(response.gasPrice),
                                                                              token: Token.Ether)))
            .change(fee: TokenAmount(amount: TokenInt(fee), token: Token.Ether))
            .change(nonce: String(nonce))
            .change(recipient: address)
            .change(data: data)
            .change(amount: TokenAmount(amount: 0, token: Token.Ether))
            .change(operation: .call)
            .change(hash: _test.encryptionService.hash(of: tx))
            .change(status: .signing)
        return tx
    }

    func deploy() throws {
        let balance = try _test.infuraService.eth_getBalance(account: address)
        assert(balance >= creationFee)
        try _test.relayService.startSafeCreation(address: address)
        let tx = try _test.waitForSafeCreationTransaction(address)
        let reciept = try _test.waitForTransaction(tx)!
        assert(reciept.status == .success)
    }

    func sign(_ tx: Transaction, by account: ExternallyOwnedAccount) {
        let sigData = _test.encryptionService.sign(transaction: tx, privateKey: account.privateKey)
        tx.add(signature: Signature(data: sigData, address: account.address))
    }

    func executeTransaction(_ tx: Transaction) throws {
        let signatures = tx.signatures.sorted { $0.address.value < $1.address.value }
            .map { _test.encryptionService.ethSignature(from: $0) }
        let request = SubmitTransactionRequest(transaction: tx, signatures: signatures)
        let response = try _test.relayService.submitTransaction(request: request)
        let hash = TransactionHash(response.transactionHash)
        tx.set(hash: hash).change(status: .pending)
        let receipt = try _test.waitForTransaction(tx.transactionHash!)!
        assert(receipt.status == .success)
    }

    func isOwner(_ address: Address) throws -> Bool {
        let proxy = SafeOwnerManagerContractProxy(self.address)
        return try proxy.isOwner(address)
    }

    func getThreshold() throws -> Int {
        let proxy = SafeOwnerManagerContractProxy(address)
        return try proxy.getThreshold()
    }

}

extension TransactionCall {

    init(sender: Address, recipient: Address, gasPrice: BigInt, amount: TokenInt) {
        self.init(from: EthAddress(hex: sender.value),
                  to: EthAddress(hex: recipient.value),
                  gasPrice: EthInt(gasPrice),
                  value: EthInt(amount))
    }

}
