//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import Common

public final class RBEReviewTransactionViewController: ReviewTransactionViewController {

    var titleString = LocalizedString("ios_replace_browser_extension", comment: "Replace browser extension")
        .replacingOccurrences(of: "\n", with: " ")
    var detailString = LocalizedString("replace_browser_extension_transaction_info",
                                       comment: "Detail for the header in review screen")
    var screenTrackingEvent: Trackable?
    var successTrackingEvent: Trackable?

    typealias SpacingCell = UITableViewCell

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let event = screenTrackingEvent {
            trackEvent(event)
        }
    }

    override func didSubmit() {
        if let event = successTrackingEvent {
            trackEvent(event)
        }
    }

    override func createCells() {
        let indexPath = IndexPathIterator()
        cells[indexPath.next()] = replaceBrowserExtensionHeaderCell()
        cells[indexPath.next()] = SpacingCell()
        cells[indexPath.next()] = SpacingCell()
        feeCellIndexPath = indexPath.next()
        cells[feeCellIndexPath] = etherTransactionFeeCell()
        cells[indexPath.next()] = confirmationCell
    }

    private func replaceBrowserExtensionHeaderCell() -> UITableViewCell {
        return settingsCell(title: titleString, details: detailString)
    }

}
