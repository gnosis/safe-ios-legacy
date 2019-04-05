//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import Common

public final class RBEReviewTransactionViewController: ReviewTransactionViewController {

    var titleString = LocalizedString("transaction.replace_browser_extension.title",
                                      comment: "Title for the header in review screen.")
    var detailString = LocalizedString("transaction.replace_browser_extension.description",
                                       comment: "Detail for header in review screen.")
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
    }

    private func replaceBrowserExtensionHeaderCell() -> UITableViewCell {
        return settingsCell(title: titleString, details: detailString)
    }

}
