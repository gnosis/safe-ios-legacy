//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class Springboard {

    static let springboard = XCUIApplication(privateWithPath: nil, bundleID: "com.apple.springboard")

    class func deleteSafeApp() {
        guard let springboard = springboard else {
            preconditionFailure("Failed to find the app")
        }
        let terminatedStates: [XCUIApplication.State] = [.unknown, .notRunning]
        if !terminatedStates.contains(XCUIApplication().state) {
            XCUIApplication().terminate()
        }
        // Resolve the query for the springboard rather than launching it
        springboard.resolve()

        let safeIcons = springboard.icons.matching(identifier: "Safe")
        for _ in (0..<safeIcons.count) {
            let icon = safeIcons.element(boundBy: 0)
            if icon.exists {
                let iconFrame = icon.frame
                let springboardFrame = springboard.frame
                icon.press(forDuration: 1.3)

                // Tap the little "X" button at approximately where it is. The X is not exposed directly
                let xOffset = CGVector(dx: (iconFrame.minX + 3) / springboardFrame.maxX,
                                       dy: (iconFrame.minY + 3) / springboardFrame.maxY)
                springboard.coordinate(withNormalizedOffset: xOffset).tap()

                delay(1)
                springboard.buttons["Delete"].tap()
                delay(2)
                XCUIDevice.shared.press(.home)
            }
        }
    }

}
