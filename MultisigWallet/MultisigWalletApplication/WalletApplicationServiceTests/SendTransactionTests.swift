//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import Common

class SendTransactionTests: BaseWalletApplicationServiceTests {

    func test_whenHandlesTransactionConfirmedMessage_thenValidatesSignature() {
        let message = TransactionConfirmedMessage(hash: Data(), signature: EthSignature(r: "1", s: "2", v: 28))

        let (transaction, signatureData, extensionAddress) = prepareTransactionForSigning(basedOn: message)
        let oldUpdateDate = transaction.updatedDate!

        _ = service.handle(message: message)

        let signedTransaction = DomainRegistry.transactionRepository.findByID(transaction.id)!
        XCTAssertEqual(signedTransaction.signatures,
                       [Signature(data: signatureData, address: extensionAddress)])
        XCTAssertGreaterThan(signedTransaction.updatedDate, oldUpdateDate)
    }

    func test_whenHandlesTransactionRejectedMessage_thenChangesStatus() {
        let message = TransactionRejectedMessage(hash: Data(), signature: EthSignature(r: "1", s: "2", v: 28))

        let (transaction, _, _) = prepareTransactionForSigning(basedOn: message)
        let oldUpdatedDate = transaction.updatedDate!

        _ = service.handle(message: message)

        let rejectedTransaction = DomainRegistry.transactionRepository.findByID(transaction.id)!
        XCTAssertTrue(rejectedTransaction.signatures.isEmpty)
        XCTAssertEqual(rejectedTransaction.status, .rejected)
        XCTAssertGreaterThan(rejectedTransaction.updatedDate, oldUpdatedDate)
        XCTAssertNotNil(transaction.rejectedDate)
    }

    func test_whenCreatesNewDraftTx_thenSavesItInRepository() {
        givenReadyToUseWallet()

        let txID = service.createNewDraftTransaction()
        let tx: Transaction! = transactionRepository.findByID(TransactionID(txID))
        XCTAssertNotNil(tx)
        let wallet = walletRepository.selectedWallet()!
        XCTAssertEqual(tx.accountID, AccountID(tokenID: Token.Ether.id, walletID: wallet.id))
        XCTAssertEqual(tx.sender, selectedWallet.address)
        XCTAssertEqual(tx.type, .transfer)
        XCTAssertNotNil(tx.createdDate)
        XCTAssertNotNil(tx.updatedDate)
    }

    func test_whenUpdatingTransaction_thenUpdatesFields() {
        givenReadyToUseWallet()
        let txID = service.createNewDraftTransaction()
        let beforeUpdateTx = transactionRepository.findByID(TransactionID(txID))!
        let oldUpdateDate = beforeUpdateTx.updatedDate
        service.updateTransaction(txID, amount: 1_000, token: ethID.id, recipient: Address.testAccount1.value)
        let tx = transactionRepository.findByID(TransactionID(txID))!
        XCTAssertEqual(tx.amount, .ether(1_000))
        XCTAssertEqual(tx.recipient, Address.testAccount1)
        XCTAssertGreaterThan(tx.updatedDate, oldUpdateDate!)
    }

    func test_whenTransactionNotFound_returnsNil() {
        XCTAssertNil(service.transactionData("some"))
    }

    func test_whenTransactionDraftCreated_returnsIt() {
        givenReadyToUseWallet()
        let txID = service.createNewDraftTransaction()
        let data = service.transactionData(txID)!
        XCTAssertEqual(data.sender, service.selectedWalletAddress!)
        XCTAssertEqual(data.recipient, "")
        XCTAssertEqual(data.amount, 0)
        XCTAssertEqual(data.fee, 0)
        XCTAssertEqual(data.id, txID)
        XCTAssertEqual(data.token, "")
        XCTAssertNotNil(data.created)
        XCTAssertNotNil(data.updated)
    }

    func test_whenTransactionDataIsThere_returnsIt() {
        givenReadyToUseWallet()
        let txID = service.createNewDraftTransaction()
        let tx = transactionRepository.findByID(TransactionID(txID))!
        tx.change(recipient: Address.testAccount1)
            .change(amount: .ether(100))
            .change(fee: .ether(10))
        transactionRepository.save(tx)
        let data = service.transactionData(txID)!
        XCTAssertEqual(data.recipient, Address.testAccount1.value)
        XCTAssertEqual(data.amount, 100)
        XCTAssertEqual(data.fee, 10)
    }

    func test_whenRequestingConfirmation_thenRequestingFeeEstimate() throws {
        let tx = givenDraftTransaction()
        _ = try service.requestTransactionConfirmation(tx.id.id)
        XCTAssertNotNil(relayService.estimateTransaction_input)
    }

    func test_whenRequestingConfirmation_thenSavesEstimationInTransaction() throws {
        let tx = givenDraftTransaction()
        _ = try service.requestTransactionConfirmation(tx.id.id)
        XCTAssertEqual(tx.fee?.amount,
                       TokenInt(tx.feeEstimate!.dataGas + tx.feeEstimate!.gas) * tx.feeEstimate!.gasPrice.amount)
    }

    func test_whenRequestingConfirmation_thenFetchesContractNonce() throws {
        let tx = givenDraftTransaction()
        _ = try service.requestTransactionConfirmation(tx.id.id)
        XCTAssertEqual(tx.nonce, String(ethereumService.nonce_output))
    }

    func test_whenRequestingConfirmation_thenCalculatesHash() throws {
        let tx = givenDraftTransaction()
        _ = try service.requestTransactionConfirmation(tx.id.id)
        XCTAssertNotNil(tx.operation)
        XCTAssertEqual(tx.hash, ethereumService.hash_of_tx_output)
    }

    func test_whenRequestingConfirmation_thenTransactionInSigningStatus() throws {
        let tx = givenDraftTransaction()
        _ = try service.requestTransactionConfirmation(tx.id.id)
        XCTAssertEqual(tx.status, .signing)
    }

    func test_whenRequestingConfirmation_thenTransactionTimestampUpdated() throws {
        let tx = givenDraftTransaction()
        let oldDate = tx.updatedDate!
        _ = try service.requestTransactionConfirmation(tx.id.id)
        let updatedTx = transactionRepository.findByID(tx.id)!
        XCTAssertGreaterThan(updatedTx.updatedDate, oldDate)
    }

    func test_whenRequestingConfirmation_thenSendsConfirmatioMessage() throws {
        let tx = givenDraftTransaction()
        _ = try service.requestTransactionConfirmation(tx.id.id)
        XCTAssertEqual(notificationService.sentMessages,
                       ["to:\(service.ownerAddress(of: .browserExtension)!) " +
                        "msg:\(notificationService.requestConfirmationMessage(for: tx, hash: tx.hash!))"])
    }

    func test_whenTransactionConfirmationRequestedBefore_thenJustSendsNewConfirmation() throws {
        let tx = givenDraftTransaction()
        _ = try service.requestTransactionConfirmation(tx.id.id)
        _ = try service.requestTransactionConfirmation(tx.id.id)
        XCTAssertEqual(notificationService.sentMessages.count, 2)
    }

    func test_whenTransactionCreated_thenWaitsForConfirmation() {
        let tx = givenDraftTransaction()
        XCTAssertEqual(service.transactionData(tx.id.id)!.status, .waitingForConfirmation)
    }

    func test_whenTransactionSignedByExtension_thenReadyToSubmit() throws {
        let message = TransactionConfirmedMessage(hash: Data(), signature: EthSignature(r: "1", s: "2", v: 28))
        _ = prepareTransactionForSigning(basedOn: message)
        let txID = service.handle(message: message)!
        XCTAssertEqual(service.transactionData(txID)!.status, .readyToSubmit)
    }

    func test_whenTransactionRejected_thenStatusIsRejected() throws {
        let message = TransactionRejectedMessage(hash: Data(), signature: EthSignature(r: "1", s: "2", v: 28))
        _ = prepareTransactionForSigning(basedOn: message)
        let txID = service.handle(message: message)!
        XCTAssertEqual(service.transactionData(txID)!.status, .rejected)
    }

    func test_whenTransactionRejectedDoubleMessage_thenStatusIsRejected() throws {
        let message = TransactionRejectedMessage(hash: Data(), signature: EthSignature(r: "1", s: "2", v: 28))
        _ = prepareTransactionForSigning(basedOn: message)
        _ = service.handle(message: message)!
        _ = prepareTransactionForSigning(basedOn: message)
        let txID = service.handle(message: message)!
        XCTAssertEqual(service.transactionData(txID)!.status, .rejected)
    }

    func test_whenTransactionIsPending_thenStatusIsPending() throws {
        let walletID = WalletID()
        let tx = Transaction(id: TransactionID(),
                             type: .transfer,
                             walletID: walletID,
                             accountID: AccountID(tokenID: Token.Ether.id, walletID: walletID))
        tx.change(sender: Address.safeAddress)
            .change(recipient: Address.testAccount1)
            .change(amount: TokenAmount.ether(1))
            .change(fee: TokenAmount.ether(1))
            .change(status: .signing)
            .set(hash: TransactionHash.test1)
            .change(status: .pending)
        transactionRepository.save(tx)
        XCTAssertEqual(service.transactionData(tx.id.id)!.status, .pending)
    }

    func test_whenSubmittingTransaction_thenAddsOwnSignature() throws {
        let message = TransactionConfirmedMessage(hash: Data(), signature: EthSignature(r: "1", s: "2", v: 28))
        _ = prepareTransactionForSigning(basedOn: message)
        let txID = service.handle(message: message)!
        _ = try service.submitTransaction(txID)
        let tx = transactionRepository.findByID(TransactionID(txID))!
        XCTAssertTrue(tx.isSignedBy(Address.deviceAddress))
    }

    func test_whenSubmittingTransaction_thenTimestamps() throws {
        let message = TransactionConfirmedMessage(hash: Data(), signature: EthSignature(r: "1", s: "2", v: 28))
        _ = prepareTransactionForSigning(basedOn: message)
        let txID = service.handle(message: message)!
        let oldTx = transactionRepository.findByID(TransactionID(txID))!
        let oldUpdatedDate = oldTx.updatedDate!
        XCTAssertNil(oldTx.submittedDate)
        _ = try service.submitTransaction(txID)
        let tx = transactionRepository.findByID(TransactionID(txID))!
        XCTAssertGreaterThan(tx.updatedDate, oldUpdatedDate)
        XCTAssertNotNil(tx.submittedDate)
    }

    func test_whenSubmittingTransaction_thenSendsRequestToRelayService() throws {
        let deviceSignature = EthSignature(r: "3", s: "4", v: 27)
        let extensionSignature = EthSignature(r: "1", s: "2", v: 28)

        let message = TransactionConfirmedMessage(hash: Data(), signature: extensionSignature)
        _ = prepareTransactionForSigning(basedOn: message)
        let txID = service.handle(message: message)!
        encryptionService.sign_output = deviceSignature

        _ = try service.submitTransaction(txID)

        let request = relayService.submitTransaction_input
        XCTAssertEqual(request?.signatures.count, 2)
    }

    func test_whenSubmittedTransaction_thenUpdatesTransactionHash() throws {
        let deviceSignature = EthSignature(r: "3", s: "4", v: 27)
        let extensionSignature = EthSignature(r: "1", s: "2", v: 28)

        let message = TransactionConfirmedMessage(hash: Data(), signature: extensionSignature)
        _ = prepareTransactionForSigning(basedOn: message)
        let txID = service.handle(message: message)!
        encryptionService.sign_output = deviceSignature
        relayService.submitTransaction_output = .init(transactionHash: TransactionHash.test2.value)

        _ = try service.submitTransaction(txID)

        let tx = transactionRepository.findByID(TransactionID(txID))!
        XCTAssertEqual(tx.transactionHash, TransactionHash.test2)
        XCTAssertEqual(tx.status, .pending)
    }

    func test_whenSubmittedTransaction_thenNotifiesBrowserExtension() throws {
        let deviceSignature = EthSignature(r: "3", s: "4", v: 27)
        let extensionSignature = EthSignature(r: "1", s: "2", v: 28)

        let message = TransactionConfirmedMessage(hash: Data(), signature: extensionSignature)
        _ = prepareTransactionForSigning(basedOn: message)
        let txID = service.handle(message: message)!
        encryptionService.sign_output = deviceSignature
        relayService.submitTransaction_output = .init(transactionHash: TransactionHash.test2.value)

        _ = try service.submitTransaction(txID)
        let tx = transactionRepository.findByID(TransactionID(txID))!

        XCTAssertEqual(notificationService.sentMessages,
                       ["to:\(service.ownerAddress(of: .browserExtension)!) " +
                        "msg:\(notificationService.transactionSentMessage(for: tx))"])
    }

    func test_whenSubscribesForTransactionUpdates_thenResetsPublisherAndSubscribes() {
        let subscriber = MySubscriber()
        eventRelay.expect_unsubscribe(subscriber)
        eventRelay.expect_subscribe(subscriber, for: TransactionStatusUpdated.self)

        service.subscribeForTransactionUpdates(subscriber: subscriber)

        XCTAssertTrue(eventRelay.verify())
    }

}
