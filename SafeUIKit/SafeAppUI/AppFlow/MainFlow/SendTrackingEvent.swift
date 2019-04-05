//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

struct SendTrackingEvent: Trackable {

    enum ScreenName: String {
        case input = "Send_Input"
        case inputActionSheet = "Send_InputActionSheet"
        case inputError = "Send_InputError"
        case inputNetworkFee = "Send_InputNetworkFee"
        case review = "Send_Review"
        case review2FARequired = "Send_Review2FARequired"
        case review2FARejected = "Send_Review2FARejected"
        case review2FAConfirmed = "Send_Review2FAConfirmed"
        case success = "Send_Success"
    }

    var token: String
    var tokenName: String
    var screenName: ScreenName
    var name: String { return Tracker.screenViewEventName }
    var rawValue: String { preconditionFailure("not used") }

    init(_ screenID: ScreenName, token: String, tokenName: String) {
        self.screenName = screenID
        self.token = token
        self.tokenName = tokenName
    }

    var parameters: [String: Any]? {
        return [Tracker.screenNameEventParameterName: screenName.rawValue,
                "token": token,
                "token_name": tokenName]
    }

}
