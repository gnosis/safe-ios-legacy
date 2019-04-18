//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import CommonTestSupport

class TransactionHeaderViewTests: XCTestCase {

    let transactionHeader = TransactionHeaderView()

    override func setUp() {
        super.setUp()
    }

    func test_whenSettingAssetImage_thenSetsImageView() {
        XCTAssertNil(transactionHeader.assetImageView.image)
        let image = UIImage()
        transactionHeader.assetImage = image
        XCTAssertTrue(transactionHeader.assetImageView.image === image)
    }

    func test_whenSettingAssetCode_thenSetsLabel() {
        XCTAssertNil(transactionHeader.assetCodeLabel.text)
        transactionHeader.assetCode = "GNO"
        XCTAssertEqual(transactionHeader.assetCodeLabel.text, "GNO")
    }

    func test_whenSettingAssetInfo_thenSetsLabel() {
        XCTAssertNil(transactionHeader.assetInfoLabel.text)
        transactionHeader.assetInfo = "test"
        XCTAssertEqual(transactionHeader.assetInfoLabel.text, "test")
    }

}
