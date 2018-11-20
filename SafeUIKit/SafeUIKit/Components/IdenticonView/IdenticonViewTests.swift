//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class IdenticonViewTests: XCTestCase {

    let view = IdenticonView()

    func test_whenChangingAddress_thenImageChanges() {
        let vc = UIViewController()
        vc.view.addSubview(view)
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        createWindow(vc)
        view.seed = "a"
        let imageA = view.imageView.image
        view.seed = "b"
        let imageB = view.imageView.image
        XCTAssertNotEqual(imageA, imageB)
    }

    func test_whenShown_thenHasCircleShape() {
        let controller = UIViewController()
        controller.view.frame = UIScreen.main.bounds
        view.frame = controller.view.bounds
        controller.view.addSubview(view)
        createWindow(controller)
        let subview = view.subviews[0]
        XCTAssertTrue(subview.clipsToBounds)
        XCTAssertEqual(subview.layer.cornerRadius, subview.bounds.width / 2)
    }

    func test_whenTap_thenCallsCompletion() {
        var didTap = false
        view.tapAction = {
            didTap = true
        }
        view.didTap()
        XCTAssertTrue(didTap)
    }

}
