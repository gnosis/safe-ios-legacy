//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import SafeUIKit

class TransactionsGroupHeaderView: BackgroundHeaderFooterView {

    internal enum Strings {
        static let pending = LocalizedString("pending_captalized",
                                             comment: "Pending transactions group header")
        static let today = DateToolsLocalized("Today").capitalized
        static let past =
            LocalizedString("ios_past", comment: "Past transactions group header").capitalized
    }

    func configure(group: TransactionGroupData) {
        label.text = name(from: group)?.uppercased()
    }

    private func name(from group: TransactionGroupData) -> String? {
        if group.type == .pending { return Strings.pending }
        guard let date = group.date else { return nil }
        if date.isToday || date.isLater(than: Date()) {
            return Strings.today
        } else {
            return Strings.past
        }
    }

}
