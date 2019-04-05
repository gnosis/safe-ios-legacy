//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import XCTest

func XCTAssertTracksAppearance(in controller: UIViewController,
                               _ event: ScreenTrackingEvent,
                               file: StaticString = #file,
                               line: UInt = #line) {
    XCTAssertTracks(event, file: file, line: line) {
        controller.viewDidAppear(false)
    }
}

func XCTAssertTracks(_ event: ScreenTrackingEvent,
                     file: StaticString = #file,
                     line: UInt = #line,
                     _ closure: () -> Void) {
    let handler = TestTrackingHandler()
    Tracker.shared.append(handler: handler)
    closure()
    let isEventTracked = handler.events.contains {
        $0.parameters?[Tracker.screenNameEventParameterName] as? String == event.rawValue
    }
    XCTAssertTrue(isEventTracked, "Event \(event) was not tracked", file: file, line: line)
    Tracker.shared.remove(handler: handler)
}

func XCTAssertTracks(file: StaticString = #file,
                     line: UInt = #line,
                     _ closure: (TestTrackingHandler) -> Void) {
    let handler = TestTrackingHandler()
    Tracker.shared.append(handler: handler)
    closure(handler)
    Tracker.shared.remove(handler: handler)
}
