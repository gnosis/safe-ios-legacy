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

    // FIXME: improve this unit test's stability
//    func test_whenSettingAssetImageURL_thenSetsImageView() {
//        XCTAssertNil(transactionHeader.assetImageView.image)
//        // swiftlint:disable:next line_length
//        let imageURL = URL(string: "https://raw.githubusercontent.com/rmeissner/crypto_resources/master/tokens/rinkeby/icons/0x979861dF79C7408553aAF20c01Cfb3f81CCf9341.png")
//        transactionHeader.assetImageURL = imageURL
//        delay(0.7) // FIXME: this is a bad unit test because it goes through network.
//        XCTAssertNotNil(transactionHeader.assetImageView.image)
//    }

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
