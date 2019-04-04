//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum SendTrackingEvent: Trackable {

    case input(token: String, tokenName: String)
    case inputActionSheet(token: String, tokenName: String)
    case inputError(token: String, tokenName: String)
    case inputNetworkFee(token: String, tokenName: String)
    case review(token: String, tokenName: String)
    case review2FARequired(token: String, tokenName: String)
    case review2FARejected(token: String, tokenName: String)
    case review2FAConfirmed(token: String, tokenName: String)
    case success(token: String, tokenName: String)

    static let tokenParameterName = "token"
    static let tokenNameParameterName = "token_name"

    var rawValue: String { return "" }
    var name: String { return Tracker.screenViewEventName }

    var parameters: [String: Any]? {
        switch self {
        case let .input(token, tokenName):
            return parameters(from: "Send_Input", token, tokenName)
        case let .inputActionSheet(token, tokenName):
            return parameters(from: "Send_InputActionSheet", token, tokenName)
        case let .inputError(token, tokenName):
            return parameters(from: "Send_InputError", token, tokenName)
        case let .inputNetworkFee(token, tokenName):
            return parameters(from: "Send_InputNetworkFee", token, tokenName)
        case let .review(token, tokenName):
            return parameters(from: "Send_Review", token, tokenName)
        case let .review2FARequired(token, tokenName):
            return parameters(from: "Send_Review2FARequired", token, tokenName)
        case let .review2FARejected(token, tokenName):
            return parameters(from: "Send_Review2FARejected", token, tokenName)
        case let .review2FAConfirmed(token, tokenName):
            return parameters(from: "Send_Review2FAConfirmed", token, tokenName)
        case let .success(token, tokenName):
            return parameters(from: "Send_Success", token, tokenName)
        }
    }

    private func parameters(from name: String, _ token: String, _ tokenName: String) -> [String: Any] {
        return [Tracker.screenNameEventParameterName: name,
                SendTrackingEvent.tokenParameterName: token,
                SendTrackingEvent.tokenNameParameterName: tokenName]
    }

}
