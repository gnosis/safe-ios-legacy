//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

class TestTrackingHandler: TrackingHandler {

    var events: [(name: String, parameters: [String: Any]?)] = []

    func track(event: String, parameters: [String: Any]?) {
        events.append((event, parameters))
    }

    func screenName(at index: Int) -> String? {
        return parameter(at: index, name: Tracker.screenNameEventParameterName)
    }

    func parameter(at index: Int, name: String) -> String? {
        return events[index].parameters?[name] as? String
    }

}

enum TestScreenTrackingEvent: String, ScreenTrackingEvent {

    case view = "TestScreenView"

}
