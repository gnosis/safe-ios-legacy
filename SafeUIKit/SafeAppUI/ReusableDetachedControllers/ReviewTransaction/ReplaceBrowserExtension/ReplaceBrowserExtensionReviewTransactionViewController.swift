//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public final class ReplaceBrowserExtensionReviewTransactionViewController: ReviewTransactionViewController {

    enum ReplaceBrowserExtensionStrings {
        static let title = LocalizedString("transaction.replace_browser_extension.title",
                                           comment: "Title for the header in review screen.")
        static let detail = LocalizedString("transaction.replace_browser_extension.description",
                                            comment: "Detail for header in review screen.")
    }

    typealias SpacingCell = UITableViewCell

    override func createCells() {
        let indexPath = IndexPathIterator()
        cells[indexPath.next()] = replaceBrowserExtensionHeaderCell()
        cells[indexPath.next()] = SpacingCell()
        cells[indexPath.next()] = SpacingCell()
        feeCellIndexPath = indexPath.next()
        cells[feeCellIndexPath] = etherTransactionFeeCell()
    }

    private func replaceBrowserExtensionHeaderCell() -> UITableViewCell {
        return settingsCell(title: ReplaceBrowserExtensionStrings.title,
                            details: ReplaceBrowserExtensionStrings.detail)
    }

}
