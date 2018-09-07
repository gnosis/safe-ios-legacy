//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

// TODO: move to UI Kit
class BlockiesViewTests: XCTestCase {

    func test_whenChangingAddress_thenImageChanges() {
        let view = BlockiesView()
        view.seed = "a"
        let imageA = view.imageView.image
        view.seed = "b"
        let imageB = view.imageView.image
        XCTAssertNotEqual(imageA, imageB)
    }

    func test_whenShown_thenHasCircleShape() {
        let view = BlockiesView()
        let controller = UIViewController()
        controller.view.frame = UIScreen.main.bounds
        view.frame = controller.view.bounds
        controller.view.addSubview(view)
        createWindow(controller)
        XCTAssertTrue(view.clipsToBounds)
        XCTAssertEqual(view.layer.cornerRadius, view.frame.width / 2)
    }

}
