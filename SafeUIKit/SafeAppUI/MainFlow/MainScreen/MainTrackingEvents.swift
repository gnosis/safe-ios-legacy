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
    case addressBook  = "AddressBook"
    case addressBookViewEntry = "AddressBook_ViewEntry"
    case addressBookEditEntry = "AddressBook_EditEntry"
    case addressBookNewEntry  = "AddressBook_NewEntry"
    case enterENSName = "EnterENSName"

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

    case replaceTwoFAWithAuthenticator              = "replace_2fa_with_authenticator"
    case connectAuthenticator                       = "connect_authenticator"
    case replaceRecoveryPhrase                      = "replace_recovery_phrase"
    case recoverSafe                                = "recover_safe"
    case disconnectAuthenticator                    = "disconnect_authenticator"
    case send                                       = "send"
    case contractUpgrade                            = "contract_upgrade"
    case replaceTwoFAWithStatusKeycard              = "replace_2fa_with_status_keycard"
    case connectStatusKeycard                       = "connect_status_keycard"
    case disconnectStatusKeycard                    = "disconnect_status_keycard"

}
