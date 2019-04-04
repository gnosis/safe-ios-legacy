//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

enum MainTrackingEvent: String, ScreenTrackingEvent {

    case assets       = "AssetView"
    case transactions = "TransactionView"
    case receiveFunds = "ReceiveFunds"
    case manageTokens = "ManageTokens"
    case addToken     = "ManageTokens_AddToken"
    case unlock       = "UnlockSafe"

}

enum TransactionDetailTrackingEvent: Trackable {

    case transactionDetails(TransactionDetailType)

    var rawValue: String { return "TransactionDetail" }

    var name: String { return Tracker.screenViewEventName }

    var parameters: [String: Any]? {
        switch self {
        case .transactionDetails(let type):
            return [Tracker.screenNameEventParameterName: rawValue,
                    "transaction_type": type.rawValue]
        }
    }

}

enum TransactionDetailType: String {

    case replaceBrowserExtension    = "replace_browser_extension"
    case connectBrowserExtension    = "connect_browser_extension"
    case replaceRecoveryPhrase      = "replace_recovery_phrase"
    case recoverSafe                = "recover_safe"
    case disconnectBrowserExtension = "disconnect_browser_extension"
    case send                       = "send"

}
