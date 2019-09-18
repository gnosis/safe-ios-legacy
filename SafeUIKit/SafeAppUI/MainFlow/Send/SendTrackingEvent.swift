//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

struct SendTrackingEvent: Trackable {

    enum ScreenName: String {
        case input                  = "Send_Input"
        case review                 = "Send_Review"
        case review2FARequired      = "Send_Review2FARequired"
        case review2FARejected      = "Send_Review2FARejected"
        case review2FAConfirmed     = "Send_Review2FAConfirmed"

        case keycard2FARequired     = "Send_Keycard2FARequired"
        case keycard2FARejected     = "Send_Keycard2FARejected"
        case keycard2FAConfirmed    = "Send_Keycard2FAConfirmed"

        case success                = "Send_Success"
    }

    static let tokenParameterName = "token"
    static let tokenNameParameterName = "token_name"

    var token: String
    var tokenName: String
    var screenName: ScreenName
    var eventName: String { return Tracker.screenViewEventName }
    var rawValue: String { preconditionFailure("not used") }

    init(_ screenID: ScreenName, token: String, tokenName: String) {
        self.screenName = screenID
        self.token = token.isEmpty ? "<null>" : token
        self.tokenName = tokenName.isEmpty ? "<null>" : tokenName
    }

    var parameters: [String: Any]? {
        return [Tracker.screenNameEventParameterName: screenName.rawValue,
                SendTrackingEvent.tokenParameterName: token,
                SendTrackingEvent.tokenNameParameterName: tokenName]
    }

}
