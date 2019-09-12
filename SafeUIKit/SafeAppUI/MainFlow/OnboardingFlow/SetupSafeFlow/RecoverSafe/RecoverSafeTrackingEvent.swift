//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum RecoverSafeTrackingEvent: String, ScreenTrackingEvent {

    case intro = "Recover_Intro"
    case inputAddress = "Recover_InputAddress"
    case enterSeed = "Recover_EnterSeed"
    case feeIntro = "Recover_RecoveryFeeIntro"
    case paymentMethod = "Recover_PaymentMethod"
    case fee  = "Recover_RecoveryFee"
    case review = "Recover_Review"
    case feePaid = "Recover_FeePaid"

}
