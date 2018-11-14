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
        let (_, _) = try createNewSafe()
    }

    private func createNewSafe() throws -> (address: Address, recoveryKey: ExternallyOwnedAccount)! {
        let deviceKey = encryptionService.generateExternallyOwnedAccount()
        let browserExtensionKey = encryptionService.generateExternallyOwnedAccount()
        let recoveryKey = encryptionService.generateExternallyOwnedAccount()
        let derivedKeyFromRecovery = encryptionService.deriveExternallyOwnedAccount(from: recoveryKey, at: 1)

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
        let ints = [response.safeTxGas, response.gasPrice, response.dataGas, response.operationalGas]
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

    private func testPrint(funder: ExternallyOwnedAccount, owners: [ExternallyOwnedAccount], safe: Safe) {
        print()
        print("Funder:")
        let addressLength = funder.address.value.count
        let privateKeyLength = funder.privateKey.data.toHexString().count
        print("Address", String(repeating: " ", count: addressLength + 1 - "Address".count), "Private Key")
        print(String(repeating: "=", count: addressLength), String(repeating: "=", count: privateKeyLength))
        print(funder.address.value, funder.privateKey.data.toHexString())
        print()
        print("Safe Owners:")
        print("Address", String(repeating: " ", count: addressLength + 1 - "Address".count), "Private Key")
        print(String(repeating: "=", count: addressLength), String(repeating: "=", count: privateKeyLength))
        for owner in owners {
            print(owner.address.value, owner.privateKey.data.toHexString())
        }
        print()
        let feeLength = String(safe.creationFee).count
        print("Safe:")
        print("Address", String(repeating: " ", count: addressLength + 1 - "Address".count), "Fee")
        print(String(repeating: "=", count: addressLength), String(repeating: "=", count: feeLength))
        print(safe.address.value, String(safe.creationFee))
        print()
    }

    func test_whenAddingOwner_thenNewOwnerExists() throws {
        let context = try deployNewSafe()

        let newOwner = createEOA()[0]
        let newThreshold = context.owners.count
        let tx = try context.safe.prepareAddOwnerTx(newOwner, threshold: newThreshold)
        try execute(transaction: tx, context: context)

        let newOwners = try context.safe.proxy.getOwners()
        XCTAssertTrue(newOwners.contains { $0.value.lowercased() == newOwner.address.value.lowercased() })
        XCTAssertTrue(try context.safe.isOwner(newOwner.address))
        XCTAssertEqual(try context.safe.getThreshold(), newThreshold)
    }

    func test_whenChangingThreshold_thenChangesIt() throws {
        let context = try deployNewSafe()

        let tx = try context.safe.prepareTx(to: context.safe.address, data: context.safe.proxy.changeThreshold(1))
        try execute(transaction: tx, context: context)

        XCTAssertEqual(try context.safe.getThreshold(), 1)
    }

    func test_whenSwappingOwner_thenSwaps() throws {
        let context = try deployNewSafe()

        let newOwner = createEOA()[0].address

        // NOTE: do not assume that local owner list is the same as remote owner list!
        let oldOwner = context.owners[1].address
        let prevOwner = try context.safe.proxy.previousOwner(to: oldOwner)!
        let tx = try context.safe.prepareTx(to: context.safe.address,
                                            data: context.safe.proxy.swapOwner(prevOwner: prevOwner,
                                                                               old: oldOwner,
                                                                               new: newOwner))
        try execute(transaction: tx, context: context)

        XCTAssertTrue(try context.safe.isOwner(newOwner))
        XCTAssertFalse(try context.safe.isOwner(oldOwner))
    }

    func test_whenRemovingOwner_thenRemoves() throws {
        let context = try deployNewSafe()

        let firstOwner = context.owners.first!.address
        // NOTE: do not assume that local owner list is the same as remote owner list!
        let prevOwner = try context.safe.proxy.previousOwner(to: firstOwner)!

        let tx = try context.safe.prepareTx(to: context.safe.address,
                                            data: context.safe.proxy.removeOwner(prevOwner: prevOwner,
                                                                                 owner: firstOwner,
                                                                                 newThreshold: 1))
        try execute(transaction: tx, context: context)

        XCTAssertFalse(try context.safe.isOwner(firstOwner))
        XCTAssertEqual(try context.safe.getThreshold(), 1)
    }

    // TODO: implement corner & error cases testing

    typealias SafeContext = (funder: ExternallyOwnedAccount, owners: [ExternallyOwnedAccount], safe: Safe)

    private func deployNewSafe() throws -> SafeContext {
            let fundingEOA = provisionFundingAccount()
            let owners = createEOA(count: 3)
            let safe = try prepareSafeCreation(owners)
            testPrint(funder: fundingEOA, owners: owners, safe: safe)
            try pay(from: fundingEOA, to: safe.address, amount: safe.creationFee)
            try safe.deploy()
            return (fundingEOA, owners, safe)
    }

    private func execute(transaction tx: Transaction, context: SafeContext) throws {
        context.owners[0..<2].forEach { context.safe.sign(tx, by: $0) }
        try pay(from: context.funder, to: context.safe.address, amount: tx.fee!.amount + tx.ethValue)
        try context.safe.executeTransaction(tx)
    }

    func provisionFundingAccount() -> ExternallyOwnedAccount {
        // funder address: 0x2333b4CC1F89a0B4C43e9e733123C124aAE977EE
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

    func pay(from sender: ExternallyOwnedAccount, to recipient: Address, amount: TokenInt, data: Data? = nil) throws {
        let gasPrice = try infuraService.eth_gasPrice()
        let callTx = TransactionCall(sender: sender.address,
                                     recipient: recipient,
                                     gasPrice: gasPrice,
                                     amount: amount,
                                     data: data)
        let gas = try infuraService.eth_estimateGas(transaction: callTx)
        let balance = try infuraService.eth_getBalance(account: sender.address)
        assert(balance >= gas * gasPrice + amount, "Not enough balance \(sender.address)")
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

    func test_tokenTransfer() throws {
        let context = try deployNewSafe()

        let erc20Proxy = ERC20TokenContractProxy(Address("0x3d5f63756C1979C596D6c9267Ee5b82935687AD9"))
        try pay(from: context.funder,
                to: erc20Proxy.contract,
                amount: 0,
                data: erc20Proxy.transfer(to: context.safe.address, amount: 1))
        XCTAssertEqual(try erc20Proxy.balance(of: context.safe.address), 1)

        let tx = try context.safe.prepareTx(to: erc20Proxy.contract,
                                            data: erc20Proxy.transfer(to: context.funder.address, amount: 1))
        try execute(transaction: tx, context: context)
        XCTAssertEqual(try erc20Proxy.balance(of: context.safe.address), 0)
    }

    func test_searchForGasAdjustment() {
        var lower: BigInt = 0
        var upper = lower
        // exponential growth until first success value
        while true {
            if do_test_send_transaction(gasAdjustment: upper) {
                print("RANGE: (failure) \(lower) - \(upper) (success)")
                break
            }
            lower = upper
            upper = upper == 0 ? 1 : (upper * 2)
        }
        // and binary search between failure and success values
        var next: BigInt
        while (upper - lower) > 0 {
            next = (lower + upper) / 2
            let success = do_test_send_transaction(gasAdjustment: next)
            if success {
                print("SUCCESS: \(next)")
                upper = next
            } else {
                lower = next
            }
        }
    }

    private func do_test_send_transaction(gasAdjustment: BigInt) -> Bool {
        print("Trying \(gasAdjustment)")
        do {
            var context = try deployNewSafe()
            context.safe.gasAdjustment = gasAdjustment
            let tx = try context.safe.prepareTx(to: context.funder.address, amount: 1, data: nil)
            try execute(transaction: tx, context: context)
            return true
        } catch {
            return false
        }
    }

    func test_whenMultipleTransactionsPerformed_thenOk() throws {
        var context = try deployNewSafe()
        context.safe.gasAdjustment = 16_250 // find your own with the test_searchForGasAdjustment()
        let tx = try context.safe.prepareTx(to: context.funder.address, amount: 1, data: nil)
        try execute(transaction: tx, context: context)
        let tx2 = try context.safe.prepareTx(to: context.funder.address, amount: 1, data: nil)
        try execute(transaction: tx2, context: context)
    }

}

struct Safe {

    var creationFee: TokenInt!
    var address: Address!

    var _test: GnosisTransactionRelayServiceTests!

    var gasAdjustment: BigInt = 0

    var proxy: SafeOwnerManagerContractProxy { return SafeOwnerManagerContractProxy(address) }

    func prepareAddOwnerTx(_ owner: ExternallyOwnedAccount, threshold: Int) throws -> Transaction {
        let data = proxy.addOwner(owner.address, newThreshold: threshold)
        return try prepareTx(to: address, data: data)
    }

    func prepareTx(to recipient: Address, amount: TokenInt = 0, data: Data? = nil) throws -> Transaction {
        let request = EstimateTransactionRequest(safe: address,
                                                 to: recipient,
                                                 value: String(amount),
                                                 data: data == nil ? "" : data!.toHexString().addHexPrefix(),
                                                 operation: .call)
        let response = try _test.relayService.estimateTransaction(request: request)
        // FIXME: gas is adjusted because currently dataGas + txGas is not enough for funding the fees.
        let fee = (BigInt(response.dataGas) + BigInt(response.safeTxGas) + BigInt(response.operationalGas) +
            gasAdjustment) * BigInt(response.gasPrice)
        let nonce = response.nextNonce
        let tx = Transaction(id: TransactionID(),
                             type: .transfer,
                             walletID: WalletID(),
                             accountID: AccountID(tokenID: Token.Ether.id, walletID: WalletID()))
        tx.change(sender: address)
            .change(feeEstimate: TransactionFeeEstimate(gas: response.safeTxGas,
                                                        dataGas: response.dataGas,
                                                        operationalGas: response.operationalGas,
                                                        gasPrice: TokenAmount(amount: TokenInt(response.gasPrice),
                                                                              token: Token.Ether)))
            .change(fee: TokenAmount(amount: TokenInt(fee), token: Token.Ether))
            .change(nonce: String(nonce))
            .change(recipient: recipient)
            .change(data: data)
            .change(amount: TokenAmount(amount: amount, token: Token.Ether))
            .change(operation: .call)
            .change(hash: _test.encryptionService.hash(of: tx))
            .proceed()
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
        let sortedSigs = tx.signatures.sorted { $0.address.value < $1.address.value }
        let ethSigs = sortedSigs.map { _test.encryptionService.ethSignature(from: $0) }
        let request = SubmitTransactionRequest(transaction: tx, signatures: ethSigs)
        let response = try _test.relayService.submitTransaction(request: request)
        let hash = TransactionHash(response.transactionHash)
        tx.set(hash: hash).proceed()
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

    init(sender: Address, recipient: Address, gasPrice: BigInt, amount: TokenInt, data: Data? = nil) {
        self.init(from: EthAddress(hex: sender.value),
                  to: EthAddress(hex: recipient.value),
                  gasPrice: EthInt(gasPrice),
                  value: EthInt(amount),
                  data: data == nil ? nil : EthData(data!))
    }

}
