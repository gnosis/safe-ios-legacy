//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ReplaceRecoveryPhraseReviewTransactionViewController: ReviewTransactionViewController {

    enum ReplaceRecoveryPhraseStrings {
        static let title = LocalizedString("replace_recovery_phrase", comment: "Title for the header in review screen")
            .replacingOccurrences(of: "\n", with: " ")
        static let detail = LocalizedString("ios_replace_seed_details",
                                            comment: "Detail for the header in review screen")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(ReplaceRecoveryPhraseTrackingEvent.review)
    }

    override func didSubmit() {
        trackEvent(ReplaceRecoveryPhraseTrackingEvent.success)
    }

    override func createCells() {
        let indexPath = IndexPathIterator()
        cells[indexPath.next()] = replaceRecoveryPhraseHeaderCell()
        feeCellIndexPath = indexPath.next()
        cells[feeCellIndexPath] = etherTransactionFeeCell()
        cells[indexPath.next()] = confirmationCell
    }

    private func replaceRecoveryPhraseHeaderCell() -> UITableViewCell {
        return settingsCell(title: ReplaceRecoveryPhraseStrings.title, details: ReplaceRecoveryPhraseStrings.detail)
    }

}
