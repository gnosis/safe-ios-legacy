//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import SafeUIKit

class TransactionsGroupHeaderView: BackgroundHeaderFooterView {

    internal enum Strings {
        static let pending = LocalizedString("transactions.group.pending_outgoing",
                                             comment: "Pending transactions group header")
        static let today = DateToolsLocalized("Today")
        static let past = LocalizedString("transactions.group.past", comment: "Past transactions group header")
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
