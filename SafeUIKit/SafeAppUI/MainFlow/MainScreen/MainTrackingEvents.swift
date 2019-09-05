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

struct TransactionDetailTrackingEvent: Trackable {

    static let transactionTypeParameterName = "transaction_type"
    var type: TransactionDetailType
    var eventName: String { return Tracker.screenViewEventName }
    var rawValue: String { return "TransactionDetail" }
    var parameters: [String: Any]? {
        return [Tracker.screenNameEventParameterName: rawValue,
                TransactionDetailTrackingEvent.transactionTypeParameterName: type.rawValue]
    }

    public init(type: TransactionDetailType) {
        self.type = type
    }

}

enum TransactionDetailType: String {

    case replaceBrowserExtension    = "replace_browser_extension"
    case connectBrowserExtension    = "connect_browser_extension"
    case replaceRecoveryPhrase      = "replace_recovery_phrase"
    case recoverSafe                = "recover_safe"
    case disconnectBrowserExtension = "disconnect_browser_extension"
    case send                       = "send"
    case contractUpgrade            = "contract_upgrade"

}
