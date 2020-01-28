//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import SafeUIKit

class TransactionsGroupHeaderView: BackgroundHeaderFooterView {

    internal enum Strings {
        static let pending = LocalizedString("pending", comment: "Pending transactions group header")
        static let today = DateToolsLocalized("Today")
        static let yesterday = DateToolsLocalized("Yesterday")
        static let signing = "Signing"
    }

    static let thisYearDateFormatter: DateFormatter = {
        // see http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        // Abbreviated month and day, for example: Apr 21
        let formatString = DateFormatter.dateFormat(fromTemplate: "dMMM", options: 0, locale: .autoupdatingCurrent)
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()

    func configure(group: TransactionGroupData) {
        title = name(from: group)?.uppercased()
    }

    private func name(from group: TransactionGroupData) -> String? {
        if group.type == .pending { return Strings.pending }
        if group.type == .signing { return Strings.signing }
        guard let date = group.date else { return nil }
        if date.isToday || date.isLater(than: Date()) {
            return Strings.today
        } else if date.isYesterday {
            return Strings.yesterday
        } else if date.isInCurrentYear {
            return type(of: self).thisYearDateFormatter.string(from: date)
        } else {
            return date.format(with: .medium)
        }
    }

}

extension Date {

    var isInCurrentYear: Bool {
        return self.year == Date().year
    }

}
