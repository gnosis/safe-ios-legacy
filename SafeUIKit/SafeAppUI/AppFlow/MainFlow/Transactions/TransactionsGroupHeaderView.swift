//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import DateTools

class TransactionsGroupHeaderView: UITableViewHeaderFooterView {

    internal enum Strings {
        // Note: these are not used yet, just for localization for now.
        static let pending = LocalizedString("transactions.group.pending", comment: "Pending transactions group header")
        static let today = DateToolsLocalizedString("Today").uppercased()
        static let yesterday = DateToolsLocalizedString("Yesterday").uppercased()
    }

    @IBOutlet weak var headerLabel: UILabel!

    func configure(group: TransactionGroupData) {
        if group.type == .pending {
            headerLabel.text = Strings.pending
            headerLabel.textColor = ColorName.blueyGrey.color
        } else {
            headerLabel.text = name(from: group.date)
            headerLabel.textColor = ColorName.battleshipGrey.color
        }
        backgroundView = UIView()
        backgroundView?.backgroundColor = .white
    }

    private func name(from date: Date?) -> String? {
        guard let date = date else { return nil }
        if date.isToday {
            return Strings.today
        } else if date.isYesterday {
            return Strings.yesterday
        } else {
            return date.format(with: .short)
        }
    }

}

fileprivate extension Bundle {
    static let DateToolsBundle = Bundle(for: DateTools.Constants.self)
}

func DateToolsLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, tableName: "DateTools", bundle: Bundle.DateToolsBundle, value: "", comment: "")
}
