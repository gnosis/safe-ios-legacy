//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

extension UIViewController {

    func trackEvent(_ event: Trackable, parameters: [String: Any]? = nil) {
        Tracker.shared.track(event: event, parameters: parameters)
    }

}
