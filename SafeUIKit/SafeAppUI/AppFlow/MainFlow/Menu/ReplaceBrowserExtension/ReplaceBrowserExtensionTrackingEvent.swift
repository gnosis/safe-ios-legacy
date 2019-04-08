//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum ReplaceBrowserExtensionTrackingEvent: String, ScreenTrackingEvent {

    case intro      = "Replace2FA"
    case scan       = "Replace2FA_Scan"
    case enterSeed  = "Replace2FA_EnterSeed"
    case review     = "Replace2FA_Review"
    case success    = "Replace2FA_Success"

}
