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
import CommonTestSupport

class HTTPGnosisTransactionRelayServiceTests: BlockchainIntegrationTest {

    var relayService: HTTPGnosisTransactionRelayService!
    let ethService = EthereumKitEthereumService()
    let walletRepo = InMemoryWalletRepository()
    var metadataRepo: InMemorySafeContractMetadataRepository!

    enum Error: String, LocalizedError, Hashable {
        case errorWhileWaitingForCreationTransactionHash
    }

    override func setUp() {
        super.setUp()
        config = try! AppConfig.loadFromBundle()!
        relayService = HTTPGnosisTransactionRelayService(url: config.relayServiceURL, logger: MockLogger())
        metadataRepo = InMemorySafeContractMetadataRepository(metadata: config.safeContractMetadata)
        DomainRegistry.put(service: metadataRepo, for: SafeContractMetadataRepository.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
    }

    func test_safeCreation() throws {
        let (_, _) = try createNewSafe()
    }

    func test_safeIs_1_1_1() throws {
        let proxy = GnosisSafeContractProxy(Address("0x46F228b5eFD19Be20952152c549ee478Bf1bf36b"))
        XCTAssertEqual(proxy.onERC1155Received(operator: .zero,
                                               from: .zero,
                                               id: 0,
                                               value: 0,
                                               calldata: Data()),
                       Data(hex: "0xf23a6e61"))
        XCTAssertEqual(try proxy.masterCopyAddress(), Address("0x34cfac646f301356faa8b21e94227e3583fe3f5f"))
    }

    func test_whenGettingGasPrice_thenReturnsIt() throws {
        let response = try relayService.gasPrice()
        let stringInts = [response.fast, response.fastest, response.standard, response.safeLow]
        let ints = stringInts.map { BigInt($0) }
        ints.forEach { XCTAssertNotNil($0, "Repsonse: \(response)") }
    }

    func test_whenEstimatingTransaction_thenReturnsEstimations() throws {
        let context = try deployNewSafe()
        let safeAddress = context.safe.address!
        let request = EstimateTransactionRequest(safe: safeAddress,
                                                 to: safeAddress,
                                                 value: "1",
                                                 data: "",
                                                 operation: .call,
                                                 gasToken: nil)
        let response = try relayService.estimateTransaction(request: request)
        let ints = [response.safeTxGas, response.gasPrice, response.baseGas, response.operationalGas]
        ints.forEach { XCTAssertNotEqual($0, 0, "Response: \(response)") }
        let address = EthAddress(hex: response.gasToken)
        XCTAssertEqual(address, .zero)
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

    func test_whenMultipleOperations_thenExecutesMultiSend() throws {
        let context = try deployNewSafe(owners: 3, confirmations: 1)

        let remoteOwners = try context.safe.proxy.getOwners()
        var linkedList = OwnerLinkedList()
        remoteOwners.forEach { linkedList.add($0) }

        let sameThreshold = try context.safe.proxy.getThreshold()
        let toRemove = context.owners[0].address
        let removeOwnerData = context.safe.proxy.removeOwner(prevOwner: linkedList.addressBefore(toRemove),
                                                             owner: toRemove,
                                                             newThreshold: sameThreshold)
        linkedList.remove(toRemove)

        let newOwnerEOA = createEOA()[0]
        let newThreshold = sameThreshold
        let addOwnerData = context.safe.proxy.addOwner(newOwnerEOA.address, newThreshold: newThreshold)
        linkedList.add(newOwnerEOA.address)

        let multiSendContract = MultiSendContractProxy()

        let txData = multiSendContract.multiSend([
            (operation: .call, to: context.safe.address, value: 0, data: removeOwnerData),
            (operation: .call, to: context.safe.address, value: 0, data: addOwnerData)])

        let tx = try context.safe.prepareTx(to: encryptionService.address(from: multiSendContract.contract.value)!,
                                            amount: 0,
                                            data: txData,
                                            operation: .delegateCall,
                                            type: .walletRecovery)

        try execute(transaction: tx, context: context, confirmations: 1)

        XCTAssertFalse(try context.safe.isOwner(toRemove))
        XCTAssertTrue(try context.safe.isOwner(newOwnerEOA.address))
        XCTAssertEqual(try context.safe.getThreshold(), newThreshold)
    }

    func test_sendingManyTransactionsOneByOne() throws {
        let postTransactionSubmissionDelay: TimeInterval = 15
        let txCount = 2

        let safeAddress = "<your safe address>"
        let recipientAddress = "<transaction recipient address>"
        let owners = ["<private keys of owners>"]
            .map(createEOA)
        let funder = provisionFundingAccount()
        var safe = Safe(owners: owners, confirmations: 1)
        safe._test = self
        safe.address = Address(safeAddress)
        safe.creationFee = TokenInt(1e10)
        let context: SafeContext = (funder, owners, safe)
        let recipient = Address(recipientAddress)
        let txAmount = TokenInt(1e14)
        try pay(from: context.funder, to: context.safe.address, amount: TokenInt(1e15))

        var transactions = [Transaction]()
        do {
            for _ in 0..<txCount {
                let tx = try context.safe.prepareTx(to: recipient, amount: txAmount)
                transactions.append(tx)
                sign(transaction: tx, context: context, signatureCount: 1)
                try context.safe.submit(transaction: tx)
                print("Submitted Transaction", tx.transactionHash!.value)
                delay(postTransactionSubmissionDelay)
            }
        } catch let error {
            XCTFail("Error sending transaction: \(error) \(transactions)")
        }
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

    func test_whenMultipleTransactionsPerformed_thenOk() throws {
        var context = try deployNewSafe()
        context.safe.gasAdjustment = 16_250 // find your own with the test_searchForGasAdjustment()
        let tx = try context.safe.prepareTx(to: context.funder.address, amount: 1, data: nil)
        try execute(transaction: tx, context: context)
        let tx2 = try context.safe.prepareTx(to: context.funder.address, amount: 1, data: nil)
        try execute(transaction: tx2, context: context)
    }

    // MARK: - Private functions

    typealias SafeContext = (funder: ExternallyOwnedAccount, owners: [ExternallyOwnedAccount], safe: Safe)

    private func createNewSafe() throws -> (address: Address, recoveryKey: ExternallyOwnedAccount)! {
        let deviceKey = encryptionService.generateExternallyOwnedAccount()
        let twoFAKey = encryptionService.generateExternallyOwnedAccount()
        let recoveryKey = encryptionService.generateExternallyOwnedAccount()
        let derivedKeyFromRecovery = encryptionService.deriveExternallyOwnedAccount(from: recoveryKey, at: 1)

        let owners = [deviceKey, twoFAKey, recoveryKey, derivedKeyFromRecovery].map { $0.address }
        // 0xd0Dab4E640D95E9E8A47545598c33e31bDb53C7c GNO
        // 0x62f25065BA60CA3A2044344955A3B2530e355111 DAI
        // 0xb3a4Bc89d8517E0e2C9B66703d09D3029ffa1e6d LOVE
        // 0xc778417E063141139Fce010982780140Aa0cD5Ab WETH
        // 0x0 - ETH
        let paymentToken = Address.zero
        let request = SafeCreationRequest(saltNonce: 1,
                                          owners: owners,
                                          confirmationCount: 2,
                                          paymentToken: paymentToken)
        let response = try relayService.createSafeCreationTransaction(request: request)

        let validator = SafeCreationResponseValidator()
        XCTAssertNoThrow(try validator.validate(response, request: request))

        try transfer(to: response.safe, amount: String(response.payment.value))

        try relayService.startSafeCreation(address: response.safeAddress)
        let txHash = try waitForSafeCreationTransaction(response.safeAddress)
        XCTAssertFalse(txHash.value.isEmpty)
        let receipt = try waitForTransaction(txHash)!
        XCTAssertEqual(receipt.status, .success)

        let proxy = GnosisSafeContractProxy(response.safeAddress)
        XCTAssertEqual(proxy.onERC1155Received(operator: .zero,
                                               from: .zero,
                                               id: 0,
                                               value: 0,
                                               calldata: Data()),
                       Data(hex: "0xf23a6e61"))

        return (response.safeAddress, recoveryKey)
    }

    internal func waitForSafeCreationTransaction(_ address: Address) throws -> TransactionHash {
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

    private func deployNewSafe(owners: Int = 3, confirmations: Int = 2) throws -> SafeContext {
            let fundingEOA = provisionFundingAccount()
            let owners = createEOA(count: owners)
            let safe = try prepareSafeCreation(owners, confirmations: confirmations)
            testPrint(funder: fundingEOA, owners: owners, safe: safe)
            try pay(from: fundingEOA, to: safe.address, amount: safe.creationFee)
            try safe.deploy()
            return (fundingEOA, owners, safe)
    }

    private func execute(transaction tx: Transaction, context: SafeContext, confirmations: Int = 2) throws {
        sign(transaction: tx, context: context, signatureCount: confirmations)
        try pay(from: context.funder, to: context.safe.address, amount: tx.fee!.amount + tx.ethValue)
        try context.safe.executeTransaction(tx)
    }

    private func sign(transaction tx: Transaction, context: SafeContext, signatureCount: Int = 2) {
        context.owners[0..<signatureCount].forEach { context.safe.sign(tx, by: $0) }
    }

    private func provisionFundingAccount() -> ExternallyOwnedAccount {
        // funder address: 0x2333b4CC1F89a0B4C43e9e733123C124aAE977EE
        return createEOA(from: "0x72a2a6f44f24b099f279c87548a93fd7229e5927b4f1c7209f7130d5352efa40")
    }

    private func createEOA(from privateKey: String) -> ExternallyOwnedAccount {
        let privateKey =
            PrivateKey(data: Data(ethHex: privateKey))
        let publicKey = PublicKey(data: ethService.createPublicKey(privateKey: privateKey.data))
        return ExternallyOwnedAccount(address: encryptionService.address(privateKey: privateKey),
                                      mnemonic: Mnemonic(words: []),
                                      privateKey: privateKey,
                                      publicKey: publicKey)
    }

    private func createEOA(count: Int = 1) -> [ExternallyOwnedAccount] {
        return (0..<count).map { _ in encryptionService.generateExternallyOwnedAccount() }
    }

    private func prepareSafeCreation(_ owners: [ExternallyOwnedAccount], confirmations: Int = 2) throws -> Safe {
        let saltNonce = encryptionService.randomSaltNonce()
        let request = SafeCreationRequest(saltNonce: saltNonce,
                                          owners: owners.map { $0.address },
                                          confirmationCount: confirmations,
                                          paymentToken: .zero)
        let response = try relayService.createSafeCreationTransaction(request: request)
        var safe = Safe(owners: owners, confirmations: confirmations)
        safe._test = self
        safe.address = response.safeAddress
        safe.creationFee = response.deploymentFee
        return safe
    }

    private func pay(from sender: ExternallyOwnedAccount,
                     to recipient: Address,
                     amount: TokenInt,
                     data: Data? = nil) throws {
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

    private func ethRawTx(callTx: TransactionCall, gas: BigInt, nonce: BigInt) -> EthRawTransaction {
        return EthRawTransaction(to: callTx.to!.hexString,
                                 value: Int(callTx.value!.value),
                                 data: callTx.data?.hexString ?? "",
                                 gas: String(gas),
                                 gasPrice: String(callTx.gasPrice!.value),
                                 nonce: Int(nonce))
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
