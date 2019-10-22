//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum DisconnectTwoFATrackingEvent: String, ScreenTrackingEvent {

    case intro      = "Disconnect2FA"
    case enterSeed  = "Disconnect2FA_EnterSeed"
    case review     = "Disconnect2FA_Review"
    case success    = "Disconnect2FA_Success"

}
