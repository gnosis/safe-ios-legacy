//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum ReplaceRecoveryPhraseTrackingEvent: String, ScreenTrackingEvent {

    case intro      = "ReplaceSeed"
    case seedIntro  = "ReplaceSeed_SeedIntro"
    case showSeed   = "ReplaceSeed_ShowSeed"
    case enterSeed  = "ReplaceSeed_EnterSeed"
    case review     = "ReplaceSeed_Review"
    case success    = "ReplaceSeed_Success"

}
