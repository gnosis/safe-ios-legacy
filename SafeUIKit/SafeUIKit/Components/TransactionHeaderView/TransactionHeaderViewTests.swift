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
        XCTAssertEqual(transactionHeader.assetImageView.image, nil)
        let image = UIImage()
        transactionHeader.assetImage = image
        XCTAssertTrue(transactionHeader.assetImageView.image === image)
    }

    func test_whenSettingAssetImageURL_thenSetsImageView() {
        XCTAssertEqual(transactionHeader.assetImageView.image, nil)
        // swiftlint:disable:next line_length
        let imageURL = URL(string: "https://raw.githubusercontent.com/rmeissner/crypto_resources/master/tokens/rinkeby/icons/0x979861dF79C7408553aAF20c01Cfb3f81CCf9341.png")
        transactionHeader.assetImageURL = imageURL
        delay(0.5)
        XCTAssertTrue(transactionHeader.assetImageView.image != nil)
    }

    func test_whenSettingAssetCode_thenSetsLabel() {
        XCTAssertEqual(transactionHeader.assetCodeLabel.text, nil)
        transactionHeader.assetCode = "GNO"
        XCTAssertEqual(transactionHeader.assetCodeLabel.text, "GNO")
    }

    func test_whenSettingAssetInfo_thenSetsLabel() {
        XCTAssertEqual(transactionHeader.assetInfoLabel.text, nil)
        transactionHeader.assetInfo = "test"
        XCTAssertEqual(transactionHeader.assetInfoLabel.text, "test")
    }

}
