//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum WCTrackingEvent: String, ScreenTrackingEvent {

    case onboarding1        = "WalletConnect_Onboarding1"
    case onboarding2        = "WalletConnect_Onboarding2"
    case onboarding3        = "WalletConnect_Onboarding3"
    case scan               = "WalletConnect_Scan"
    case sessionList        = "WalletConnect_SessionList"
    case batched            = "WalletConnect_BatchTransactions"
    case completed          = "WalletConnect_MobileRequestCompleted"
    case selectSafe         = "WalletConnect_SelectSafe"

}
