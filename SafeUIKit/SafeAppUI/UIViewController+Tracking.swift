//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

extension UIViewController {

    /// Convenience method for tracking event from the view controller
    ///
    /// - Parameters:
    ///   - event: occurred event
    ///   - parameters: optional parameters
    func trackEvent(_ event: Trackable, parameters: [String: Any]? = nil) {
        Tracker.shared.track(event: event, parameters: parameters)
    }

}
