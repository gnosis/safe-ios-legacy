//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import SafeUIKit
import BigInt
import Common
import MultisigWalletApplication

class SendReviewViewController: ReviewTransactionViewController {

    var backButtonItem: UIBarButtonItem!
    var onBack: (() -> Void)?

    override func willMove(toParent parent: UIViewController?) {
        backButtonItem = UIBarButtonItem.backButton(target: self, action: #selector(back))
        setCustomBackButton(backButtonItem)
    }

    @objc func back() {
        onBack?()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if hasBrowserExtension {
            trackScreenEvent(.review2FARequired)
        } else if hasKeycard {
            trackScreenEvent(.keycard2FARequired)
        } else {
            trackScreenEvent(.review)
        }
    }

    override func didConfirm() {
        if hasKeycard {
            trackScreenEvent(.keycard2FAConfirmed)
        } else {
            trackScreenEvent(.review2FAConfirmed)
        }
    }

    override func didReject() {
        if hasKeycard {
            trackScreenEvent(.keycard2FARejected)
        } else {
            trackScreenEvent(.review2FARejected)
        }
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

    func transferViewCell() -> UITableViewCell {
        let cell = TransferViewCell(frame: .zero)
        cell.transferView.fromAddress = tx.sender
        cell.transferView.fromAddressName = ApplicationServiceRegistry.walletService.addressName(for: tx.sender)
        cell.transferView.toAddress = tx.recipient
        cell.transferView.toAddressName = ApplicationServiceRegistry.walletService.addressName(for: tx.recipient)
        cell.transferView.tokenData = tx.amountTokenData
        cell.transferView.balanceData = tx.amountTokenData.withBalance(balance(of: tx.amountTokenData))
        return cell
    }

    func feeCalculationCell() -> UITableViewCell {
        let cell = FeeCalculationCell(frame: .zero)
        var balanceAfter = subtract(balance(of: tx.amountTokenData), abs(tx.amountTokenData.balance) ?? 0)

        if tx.amountTokenData.address == tx.feeTokenData.address {
            balanceAfter = subtract(balanceAfter, abs(tx.feeTokenData.balance) ?? 0)
            let calculation = SameTransferAndPaymentTokensFeeCalculation()
            calculation.networkFeeLine.set(value: abs(tx.feeTokenData), roundUp: true)
            calculation.resultingBalanceLine.set(value: tx.amountTokenData.withBalance(balanceAfter))
            if let balance = balanceAfter, balance < 0 {
                calculation.setBalanceError(FeeCalculationError.insufficientBalance)
            }
            cell.feeCalculationView.calculation = calculation
        } else {
            let feeResultingBalance = subtract(balance(of: tx.feeTokenData) ?? 0, abs(tx.feeTokenData.balance) ?? 0)
            let calculation = DifferentTransferAndPaymentTokensFeeCalculation()
            calculation.resultingBalanceLine.set(value: tx.amountTokenData.withBalance(balanceAfter))
            if let balance = balanceAfter, balance < 0 {
                calculation.setBalanceError(FeeCalculationError.insufficientBalance)
            }
            calculation.networkFeeLine.set(value: abs(tx.feeTokenData), roundUp: true)
            calculation.networkFeeResultingBalanceLine.set(value: tx.feeTokenData.withBalance(feeResultingBalance))
            if let balance = feeResultingBalance, balance < 0 {
                calculation.setFeeBalanceError(FeeCalculationError.insufficientBalance)
            }
            cell.feeCalculationView.calculation = calculation
        }
        cell.feeCalculationView.update()
        return cell
    }

}
