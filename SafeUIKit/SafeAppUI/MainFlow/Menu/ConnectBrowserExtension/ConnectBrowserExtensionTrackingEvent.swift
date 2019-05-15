//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum ConnectBrowserExtensionTrackingEvent: String, ScreenTrackingEvent {

    case intro      = "Connect2FA"
    case review     = "Connect2FA_Review"
    case success    = "Connect2FA_Success"

}
