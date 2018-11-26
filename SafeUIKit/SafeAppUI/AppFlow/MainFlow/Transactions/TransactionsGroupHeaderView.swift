//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class TransactionsGroupHeaderView: UITableViewHeaderFooterView {

    internal enum Strings {
        static let pending = LocalizedString("transactions.group.pending_outgoing",
                                             comment: "Pending transactions group header")
        static let today = DateToolsLocalized("Today")
        static let past = LocalizedString("transactions.group.past", comment: "Past transactions group header")
    }

    @IBOutlet weak var headerLabel: UILabel!

    func configure(group: TransactionGroupData) {
        headerLabel.text = name(from: group)?.uppercased()
        headerLabel.textColor = .white
        backgroundView = UIView()
        backgroundView?.backgroundColor = .clear
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
