//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ReplaceBrowserExtensionReviewTransactionViewController: ReviewTransactionViewController {

    enum ReplaceBrowserExtensionStrings {
        static let title = LocalizedString("transaction.replace_browser_extension.title",
                                           comment: "Title for the header in review screen.")
        static let detail = LocalizedString("transaction.replace_browser_extension.description",
                                            comment: "Detail for header in review screen.")
    }

    private func replaceBrowserExtensionHeaderCell() -> UITableViewCell {
        return settingsCell(title: ReplaceBrowserExtensionStrings.title,
                            details: ReplaceBrowserExtensionStrings.detail)
    }

}
