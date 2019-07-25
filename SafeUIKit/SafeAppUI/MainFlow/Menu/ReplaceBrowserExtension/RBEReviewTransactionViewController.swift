//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

public class RBEReviewTransactionViewController: ReviewTransactionViewController {

    var titleString = LocalizedString("ios_replace_browser_extension", comment: "Replace browser extension")
        .replacingOccurrences(of: "\n", with: " ")
    var detailString = LocalizedString("replace_browser_extension_transaction_info",
                                       comment: "Detail for the header in review screen")
    var screenTrackingEvent: Trackable?
    var successTrackingEvent: Trackable?

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

    override func updateTransactionFeeCell() {
        precondition(Thread.isMainThread)
        cells[feeCellIndexPath] = feeCalculationCell()
        if feeCellIndexPath.row < tableView.numberOfRows(inSection: feeCellIndexPath.section) {
            tableView.reloadRows(at: [feeCellIndexPath], with: .none)
        }
    }

    override func createCells() {
        let indexPath = IndexPathIterator()
        cells[indexPath.next()] = replaceBrowserExtensionHeaderCell()
        feeCellIndexPath = indexPath.next()
        cells[feeCellIndexPath] = feeCalculationCell()
        cells[indexPath.next()] = confirmationCell
    }

    private func replaceBrowserExtensionHeaderCell() -> UITableViewCell {
        return settingsCell(title: titleString, details: detailString)
    }

    private func feeCalculationCell() -> UITableViewCell {
        class ReviewFeeCell: FeeCalculationCell {
            override var horizontalMargin: CGFloat { return 0 }
        }
        let cell = ReviewFeeCell(frame: .zero)
        cell.feeCalculationView.calculation = feeCalculation()
        cell.feeCalculationView.update()
        return cell
    }

    internal func feeCalculation() -> OwnerModificationFeeCalculation {
        let calculation = OwnerModificationFeeCalculation()
        let currentFeeTokenBalance = balance(of: tx.feeTokenData)
        let resultingFeeTokenBalance = subtract(currentFeeTokenBalance, abs(tx.feeTokenData.balance) ?? 0)
        calculation.currentBalanceLine.set(value: tx.feeTokenData.withBalance(currentFeeTokenBalance))
        calculation.resultingBalanceLine.set(value: tx.feeTokenData.withBalance(resultingFeeTokenBalance))
        calculation.networkFeeLine.set(value: abs(tx.feeTokenData), roundUp: true)
        return calculation
    }

}
