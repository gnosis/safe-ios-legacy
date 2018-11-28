//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class TransactionConfirmationViewTests: XCTestCase {

    let confirmationView = TransactionConfirmationView()

    func test_whenSetsUndefined_thenPropertiesAreCorrect() {
        assertView(isError: false,
                   isIntermediate: false,
                   progress: 0,
                   statusText: TransactionConfirmationView.Strings.awaitingConfirmation,
                   extensionText: TransactionConfirmationView.Strings.confirmationExplanation,
                   extensionImage: Asset.BrowserExtension.awaiting.image,
                   line: #line)
    }

    func test_whenSetsPending_thenPropertiesAreCorrect() {
        confirmationView.status = .pending
        assertView(isError: false,
                   isIntermediate: true,
                   progress: 0,
                   statusText: TransactionConfirmationView.Strings.awaitingConfirmation,
                   extensionText: TransactionConfirmationView.Strings.confirmationExplanation,
                   extensionImage: Asset.BrowserExtension.awaiting.image,
                   line: #line)
    }

    func test_whenSetsConfirmed_thenPropertiesAreCorrect() {
        confirmationView.status = .pending
        confirmationView.status = .confirmed
        assertView(isError: false,
                   isIntermediate: false,
                   progress: 1.00,
                   statusText: TransactionConfirmationView.Strings.confirmed,
                   extensionText: nil,
                   extensionImage: nil,
                   line: #line)
    }

    func test_whenSetsRejected_thenPropertiesAreCorrect() {
        confirmationView.status = .pending
        confirmationView.status = .rejected
        assertView(isError: true,
                   isIntermediate: false,
                   progress: 0,
                   statusText: TransactionConfirmationView.Strings.rejected,
                   extensionText: TransactionConfirmationView.Strings.rejectionExplanation,
                   extensionImage: Asset.BrowserExtension.rejected.image,
                   line: #line)
    }

    private func assertView(isError: Bool,
                            isIntermediate: Bool,
                            progress: Double,
                            statusText: String?,
                            extensionText: String?,
                            extensionImage: UIImage?,
                            line: UInt) {
        XCTAssertEqual(confirmationView.progressView.isError, isError, line: line)
        XCTAssertEqual(confirmationView.progressView.isIndeterminate, isIntermediate, line: line)
        XCTAssertEqual(confirmationView.progressView.progress, progress, line: line)
        XCTAssertEqual(confirmationView.statusLabel.text, statusText, line: line)
        XCTAssertEqual(confirmationView.browserExtensionLabel.text, extensionText, line: line)
        XCTAssertEqual(confirmationView.browserExtensionImageView.image, extensionImage, line: line)
    }

}
