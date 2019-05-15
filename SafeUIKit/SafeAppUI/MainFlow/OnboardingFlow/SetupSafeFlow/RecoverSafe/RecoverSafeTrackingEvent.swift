//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum RecoverSafeTrackingEvent: String, ScreenTrackingEvent {

    case intro = "Recover_Intro"
    case inputAddress = "Recover_InputAddress"
    case enterSeed = "Recover_EnterSeed"
    case twoFA = "Recover_2FA"
    case twoFAScan = "Recover_2FAScan"
    case review = "Recover_Review"
    case feePaid = "Recover_FeePaid"

}
