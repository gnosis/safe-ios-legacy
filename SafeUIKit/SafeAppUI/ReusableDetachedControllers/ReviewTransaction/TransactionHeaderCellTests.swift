//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class TransactionHeaderCellTests: XCTestCase {

    var cell: TransactionHeaderCell!

    override func setUp() {
        super.setUp()
        cell = TransactionHeaderCell(style: .default, reuseIdentifier: "cell")
    }

    func test_whenConfiguring_thenSetsProperties() {
        let url = URL(string: "gnosis.pm")!
        cell.configure(imageURL: url, code: "GNO", info: "Test")
        XCTAssertEqual(cell.transactionHeaderView.assetImageURL, url)
        XCTAssertEqual(cell.transactionHeaderView.assetCode, "GNO")
        XCTAssertEqual(cell.transactionHeaderView.assetInfo, "Test")
        cell.configure(imageURL: nil, code: "OWL", info: "Test 2")
        XCTAssertEqual(cell.transactionHeaderView.assetImage, Asset.ethIcon.image)
        XCTAssertEqual(cell.transactionHeaderView.assetCode, "OWL")
        XCTAssertEqual(cell.transactionHeaderView.assetInfo, "Test 2")
    }

}
