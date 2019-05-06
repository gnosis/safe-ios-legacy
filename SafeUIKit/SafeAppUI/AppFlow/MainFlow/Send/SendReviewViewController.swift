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

    override func updateEtherFeeBalanceCell() {
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
        cell.transferView.balanceData = tx.amountTokenData.withBalance(balance(of: tx.amountTokenData))
        return cell
    }

    private func feeCalculationCell() -> UITableViewCell {
        let cell = FeeCalculationCell(frame: .zero)
        let amountBalance = self.balance(of: tx.amountTokenData)
        let amountResultingBalance = amountBalance - abs(tx.amountTokenData.balance ?? 0)

        if tx.amountTokenData.address == tx.feeTokenData.address {
            let calculation = SendEthFeeCalculation()
            calculation.networkFeeLine.set(value: tx.feeTokenData.withNonNegativeBalance())
            calculation.resultingBalanceLine.set(value: tx.amountTokenData.withBalance(amountResultingBalance))
            cell.feeCalculationView.calculation = calculation
        } else {
            let feeBalance = self.balance(of: tx.feeTokenData)
            let feeResultingBalance = feeBalance - abs(tx.feeTokenData.balance ?? 0)
            let calculation = SendERC20FeeCalculation()
            calculation.resultingBalanceLine.set(value: tx.amountTokenData.withBalance(amountResultingBalance))
            calculation.networkFeeLine.set(value: tx.feeTokenData.withNonNegativeBalance())
            calculation.networkFeeResultingBalanceLine.set(value: tx.feeTokenData.withBalance(feeResultingBalance))
            cell.feeCalculationView.calculation = calculation
        }
        cell.feeCalculationView.update()
        return cell
    }

}
