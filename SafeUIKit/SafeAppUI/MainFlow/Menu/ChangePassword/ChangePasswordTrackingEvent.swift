//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum ChangePasswordTrackingEvent: String, ScreenTrackingEvent {

    case current    = "ChangePassword_Current"
    case new        = "ChangePassword_New"
    case success    = "ChangePassword_Success"

}
