//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class TransactionConfirmationViewTests: XCTestCase {

    let confirmationView = TransactionConfirmationView()

    func test_whenSetsIndefined_thenPropertiesAreCorrect() {
        XCTAssertFalse(confirmationView.progressView.isError)
        XCTAssertFalse(confirmationView.progressView.isIndeterminate)
        XCTAssertEqual(confirmationView.progressView.progress, 0)
        XCTAssertEqual(confirmationView.statusLabel.text, " ")
        XCTAssertNil(confirmationView.browserExtensionImageView.image)
        XCTAssertEqual(confirmationView.browserExtensionLabel.text, " ")
    }

    func test_whenSetsPending_thenPropertiesAreCorrect() {
        confirmationView.status = .pending
        XCTAssertFalse(confirmationView.progressView.isError)
        XCTAssertTrue(confirmationView.progressView.isIndeterminate)
        XCTAssertEqual(confirmationView.progressView.progress, 0)
        XCTAssertEqual(confirmationView.statusLabel.text, TransactionConfirmationView.Strings.awaitingConfirmation)
        XCTAssertEqual(confirmationView.browserExtensionImageView.image, Asset.BrowserExtension.awaiting.image)
        XCTAssertEqual(confirmationView.browserExtensionLabel.text,
                       TransactionConfirmationView.Strings.confirmationExplanation)
    }

    func test_whenSetsConfirmed_thenPropertiesAreCorrect() {
        confirmationView.status = .pending
        confirmationView.status = .confirmed
        XCTAssertFalse(confirmationView.progressView.isError)
        XCTAssertFalse(confirmationView.progressView.isIndeterminate)
        XCTAssertEqual(confirmationView.progressView.progress, 1.0)
        XCTAssertEqual(confirmationView.statusLabel.text, TransactionConfirmationView.Strings.confirmed)
        XCTAssertNil(confirmationView.browserExtensionImageView.image)
        XCTAssertEqual(confirmationView.browserExtensionLabel.text, " ")
    }

    func test_whenSetsRejected_thenPropertiesAreCorrect() {
        confirmationView.status = .pending
        confirmationView.status = .rejected
        XCTAssertTrue(confirmationView.progressView.isError)
        XCTAssertFalse(confirmationView.progressView.isIndeterminate)
        XCTAssertEqual(confirmationView.progressView.progress, 0)
        XCTAssertEqual(confirmationView.statusLabel.text, TransactionConfirmationView.Strings.rejected)
        XCTAssertEqual(confirmationView.browserExtensionImageView.image, Asset.BrowserExtension.rejected.image)
        XCTAssertEqual(confirmationView.browserExtensionLabel.text,
                       TransactionConfirmationView.Strings.rejectionExplanation)
    }

}
