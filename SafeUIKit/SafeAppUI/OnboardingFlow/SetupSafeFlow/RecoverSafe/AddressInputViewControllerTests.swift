//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
import Common
@testable import SafeAppUI

class AddressInputViewControllerTests: XCTestCase {

    func test_tracking() {
        XCTAssertTracksAppearance(in: AddressInputViewController.create(delegate: nil),
                                  RecoverSafeTrackingEvent.inputAddress)
    }

}
