//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import SafeUIKit

final class FundsTransferReviewTransactionViewController: ReviewTransactionViewController {

    override func createCells() {
        cells = [IndexPath: UITableViewCell]()
        let indexPath = IndexPathIterator()
        cells[indexPath.next()] = transferHeaderCell()
        cells[indexPath.next()] = transferViewCell()
        if tx.amountTokenData.isEther {
            feeCellIndexPath = indexPath.next()
            cells[feeCellIndexPath] = etherTransactionFeeCell()
        } else {
            cells[indexPath.next()] = tokenBalanceCell()
            feeCellIndexPath = indexPath.next()
            cells[feeCellIndexPath] = etherFeeBalanceCell()
        }
        cells[indexPath.next()] = confirmationCell
    }

    override func updateEtherFeeBalanceCell() {
        if tx.amountTokenData.isEther {
            cells[feeCellIndexPath] = etherTransactionFeeCell()
        } else {
            cells[feeCellIndexPath] = etherFeeBalanceCell()
        }
        if feeCellIndexPath.row < tableView.numberOfRows(inSection: feeCellIndexPath.section) {
            tableView.reloadRows(at: [feeCellIndexPath], with: .none)
        }
    }

    private func transferHeaderCell() -> UITableViewCell {
        let cell = TransactionHeaderCell(frame: .zero)
        cell.configure(imageURL: tx.amountTokenData.logoURL,
                       code: tx.amountTokenData.code,
                       info: Strings.outgoingTransfer)
        return cell
    }

    private func transferViewCell() -> UITableViewCell {
        let cell = TransferViewCell(frame: .zero)
        cell.transferView.fromAddress = tx.sender
        cell.transferView.toAddress = tx.recipient
        cell.transferView.tokenData = tx.amountTokenData
        return cell
    }

    private func tokenBalanceCell() -> UITableViewCell {
        let balance = self.balance(of: tx.amountTokenData)
        let resultingBalance = balance - abs(tx.amountTokenData.balance ?? 0)
        return feeCell(currentBalance: tx.amountTokenData.withBalance(balance),
                       transactionFee: nil,
                       resultingBalance: tx.amountTokenData.withBalance(resultingBalance))
    }

    private func etherFeeBalanceCell() -> UITableViewCell {
        let balance = self.balance(of: tx.feeTokenData)
        let resultingBalance = balance - abs(tx.feeTokenData.balance ?? 0)
        return feeCell(currentBalance: nil,
                       transactionFee: tx.feeTokenData,
                       resultingBalance: tx.feeTokenData.withBalance(resultingBalance))
    }

}
