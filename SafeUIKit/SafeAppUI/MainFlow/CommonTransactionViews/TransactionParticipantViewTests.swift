//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class TransactionParticipantViewTests: XCTestCase {

    func test_whenDataChanges_thenViewContentsChange() {
        let view = TransactionParticipantView()
        view.name = "test"
        XCTAssertEqual(view.nameLabel.text, "test")
        view.address = "test"
        XCTAssertEqual(view.addressLabel.text, "test")
        view.text = "my text"
        XCTAssertEqual(view.textLabel.text, "my text")
        XCTAssertTrue(view.nonTextStack.isHidden)
        XCTAssertFalse(view.textLabel.isHidden)
    }

}
