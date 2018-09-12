//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit


class QRCodeViewTests: XCTestCase {

    let view = QRCodeView()

    override func setUp() {
        super.setUp()
    }

    func test_whenChangingValue_thenImageChanges() {
        view.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        view.value = "a"
        let imageA = view.imageView.image
        view.value = "b"
        let imageB = view.imageView.image
        XCTAssertNotEqual(imageA, imageB)
    }

}
