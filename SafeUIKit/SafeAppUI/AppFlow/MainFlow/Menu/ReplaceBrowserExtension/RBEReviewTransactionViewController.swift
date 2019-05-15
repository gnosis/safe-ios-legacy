//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

public final class RBEReviewTransactionViewController: ReviewTransactionViewController {

    var titleString = LocalizedString("replace_browser_extension", comment: "Replace browser extension")
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
        cells[indexPath.next()] = SpacingCell()
        cells[indexPath.next()] = SpacingCell()
        feeCellIndexPath = indexPath.next()
        cells[feeCellIndexPath] = feeCalculationCell()
        cells[indexPath.next()] = confirmationCell
    }

    private func replaceBrowserExtensionHeaderCell() -> UITableViewCell {
        return settingsCell(title: titleString, details: detailString)
    }

    private func feeCalculationCell() -> UITableViewCell {
        let cell = FeeCalculationCell(frame: .zero)
        let calculation = OwnerModificationFeeCalculation()
        let currentFeeTokenBalance = balance(of: tx.feeTokenData)!
        let resultingFeeTokenBalance = currentFeeTokenBalance - abs(tx.feeTokenData.balance ?? 0)
        calculation.currentBalanceLine.set(value: tx.feeTokenData.withBalance(currentFeeTokenBalance))
        calculation.networkFeeLine.set(value: tx.feeTokenData.withNonNegativeBalance())
        calculation.resultingBalanceLine.set(value: tx.feeTokenData.withBalance(resultingFeeTokenBalance))
        cell.feeCalculationView.calculation = calculation
        cell.feeCalculationView.update()
        return cell
    }

}
