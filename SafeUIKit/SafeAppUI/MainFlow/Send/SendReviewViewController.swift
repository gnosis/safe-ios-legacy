//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import SafeUIKit

final class SendReviewViewController: ReviewTransactionViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreenEvent(hasBrowserExtension ? .review2FARequired : .review)
    }

    override func didConfirm() {
        trackScreenEvent(.review2FAConfirmed)
    }

    override func didReject() {
        trackScreenEvent(.review2FARejected)
    }

    override func didSubmit() {
        trackScreenEvent(.success)
    }

    private func trackScreenEvent(_ type: SendTrackingEvent.ScreenName) {
        trackEvent(SendTrackingEvent(type, token: tx.amountTokenData.address, tokenName: tx.amountTokenData.code))
    }

    override func createCells() {
        let indexPath = IndexPathIterator()
        cells[indexPath.next()] = transferViewCell()
        feeCellIndexPath = indexPath.next()
        cells[feeCellIndexPath] = feeCalculationCell()
        cells[indexPath.next()] = confirmationCell
    }

    override func updateTransactionFeeCell() {
        precondition(Thread.isMainThread)
        cells[feeCellIndexPath] = feeCalculationCell()
        if feeCellIndexPath.row < tableView.numberOfRows(inSection: feeCellIndexPath.section) {
            tableView.reloadRows(at: [feeCellIndexPath], with: .none)
        }
    }

    private func transferViewCell() -> UITableViewCell {
        let cell = TransferViewCell(frame: .zero)
        cell.transferView.fromAddress = tx.sender
        cell.transferView.toAddress = tx.recipient
        cell.transferView.tokenData = tx.amountTokenData
        cell.transferView.balanceData = tx.amountTokenData.withBalance(balance(of: tx.amountTokenData)!)
        return cell
    }

    private func feeCalculationCell() -> UITableViewCell {
        let cell = FeeCalculationCell(frame: .zero)
        let amountBalance = balance(of: tx.amountTokenData)!
        var balanceAfter = max(amountBalance - abs(tx.amountTokenData.balance ?? 0), 0)

        if tx.amountTokenData.address == tx.feeTokenData.address {
            balanceAfter = max(balanceAfter - (tx.feeTokenData.withNonNegativeBalance().balance ?? 0), 0)
            let calculation = SameTransferAndPaymentTokensFeeCalculation()
            calculation.networkFeeLine.set(value: tx.feeTokenData.withNonNegativeBalance(), roundUp: true)
            calculation.resultingBalanceLine.set(value: tx.amountTokenData.withBalance(balanceAfter))
            cell.feeCalculationView.calculation = calculation
        } else {
            let feeBalance = balance(of: tx.feeTokenData) ?? 0
            let feeResultingBalance = max(feeBalance - abs(tx.feeTokenData.balance ?? 0), 0)
            let calculation = DifferentTransferAndPaymentTokensFeeCalculation()
            calculation.resultingBalanceLine.set(value: tx.amountTokenData.withBalance(balanceAfter))
            calculation.networkFeeLine.set(value: tx.feeTokenData.withNonNegativeBalance(), roundUp: true)
            calculation.networkFeeResultingBalanceLine.set(value: tx.feeTokenData.withBalance(feeResultingBalance))
            cell.feeCalculationView.calculation = calculation
        }
        cell.feeCalculationView.update()
        return cell
    }

}
