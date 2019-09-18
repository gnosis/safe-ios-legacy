//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class ReplaceTwoFADomainServiceSigningTests: ReplaceTwoFADomainServiceBaseTestCase {

    func test_whenNewOnwerAddressIsOwner_thenThrows() {
        setUpWallet()
        _ = service.createTransaction()
        let existingOwner = Address.testAccount1
        mockProxy.getOwners_result = [existingOwner]
        XCTAssertThrowsError(try service.validateNewOwnerAddress(existingOwner.value))
    }

    func test_whenSigningTransaction_thenSetsRequiredFields() throws {
        loadEOAToMock()
        let expectedHash = Data(repeating: 1, count: 32)
        mockEncryptionService.hash_of_tx_output = expectedHash
        var tx = createEstimatedTransaction()

        XCTAssertNotNil(tx.sender)
        XCTAssertNil(tx.hash)
        XCTAssertEqual(tx.status, .draft)

        try service.sign(transactionID: tx.id, with: "Phrase")
        tx = transaction(from: tx.id)!
        XCTAssertEqual(tx.hash, expectedHash)
        XCTAssertEqual(tx.status, .signing)
    }

    func test_whenSigningWithPhrase_thenDerivesEOAFromPhrase() {
        loadEOAToMock()
        let actual = service.signingEOA(from: "phrase")!
        let expected = (ExternallyOwnedAccount.testAccount, ExternallyOwnedAccount.testAccountAt1)
        XCTAssertEqual(actual.primary, expected.0)
        XCTAssertEqual(actual.derived, expected.1)
    }

    func test_whenSigning_thenSignsWithBothKeys() throws {
        loadEOAToMock()
        let signatureData = Data(repeating: 3, count: 32)
        var tx = createEstimatedTransaction()
        mockEncryptionService.signTransactionPrivateKey_output = signatureData
        try service.sign(transactionID: tx.id, with: "Phrase")
        tx = transaction(from: tx.id)!
        XCTAssertEqual(tx.signatures, [Signature(data: signatureData,
                                                 address: ExternallyOwnedAccount.testAccount.address),
                                       Signature(data: signatureData,
                                                 address: ExternallyOwnedAccount.testAccountAt1.address)])
    }

    func test_whenPhraseIncorrect_thenThrows() {
        let tx = createEstimatedTransaction()
        mockEncryptionService.deriveExternallyOwnedAccountFromMnemonicResult = nil
        XCTAssertThrowsError(try service.sign(transactionID: tx.id, with: "Phrase"))
    }

    func test_whenKeysAreNotOwners_thenThrows() {
        let tx = createEstimatedTransaction()

        // not found
        loadEOAToMock()
        mockProxy.getOwners_result = []
        XCTAssertThrowsError(try service.sign(transactionID: tx.id, with: "Phrase"))

        // 1 of 2
        loadEOAToMock()
        mockProxy.getOwners_result = [ExternallyOwnedAccount.testAccount.address]
        XCTAssertThrowsError(try service.sign(transactionID: tx.id, with: "Phrase"))

        loadEOAToMock()
        mockProxy.getOwners_result = [ExternallyOwnedAccount.testAccountAt1.address]
        XCTAssertThrowsError(try service.sign(transactionID: tx.id, with: "Phrase"))

        // lowercase / uppercase
        loadEOAToMock()
        mockProxy.getOwners_result = [ExternallyOwnedAccount.testAccountAt1.address.value.lowercased(),
                                      ExternallyOwnedAccount.testAccount.address.value.lowercased()].map(Address.init)
        XCTAssertNoThrow(try service.sign(transactionID: tx.id, with: "Phrase"))
    }

}
