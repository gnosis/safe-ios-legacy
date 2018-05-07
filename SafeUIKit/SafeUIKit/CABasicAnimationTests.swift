//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class CABasicAnimationTests: XCTestCase {

    func test_shakeAnimation() {
        let animation = CABasicAnimation.shake(center: .zero)
        XCTAssertTrue(animation.autoreverses)
        guard let from = animation.fromValue as? CGPoint, let to = animation.toValue as? CGPoint else {
            XCTFail("Wrong animation configuration")
            return
        }
        XCTAssertTrue(from.x < 0)
        XCTAssertTrue(from.y == 0)
        XCTAssertTrue(to.x > 0)
        XCTAssertTrue(to.y == 0)
        XCTAssertTrue(animation.repeatCount > 1)
        XCTAssertTrue(animation.duration > 0)
    }

}
