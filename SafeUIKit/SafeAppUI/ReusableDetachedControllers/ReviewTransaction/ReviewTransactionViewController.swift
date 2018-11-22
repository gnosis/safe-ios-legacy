//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common
import BigInt

final class ReviewTransactionViewController: UITableViewController {

    private var tx: TransactionData!
    private var cells = [IndexPath: UITableViewCell]()

    enum Strings {
        static let outgoingTransfer = LocalizedString("transaction.outgoing_transfer", comment: "Outgoing transafer")
    }

    convenience init(transactionID: String) {
        self.init()
        tx = ApplicationServiceRegistry.walletService.transactionData(transactionID)!
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        createCells()
    }

    private func configureTableView() {
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundView = BackgroundImageView(frame: tableView.frame)
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
    }

    // MARK: - table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath]!
    }

    // MARK: Table view cell creation

    private func createCells() {
        cells[IndexPath(row: 0, section: 0)] = headerCell()
        cells[IndexPath(row: 1, section: 0)] = transferViewCell()
        cells[IndexPath(row: 2, section: 0)] = confirmationCell()
        if tx.amountTokenData.isEther {
           cells[IndexPath(row: 3, section: 0)] = etherTransactionFeeCell()
        } else {
            cells[IndexPath(row: 3, section: 0)] = tokenBalanceChangeCell()
            cells[IndexPath(row: 4, section: 0)] = etherFeeBalanceChangeCell()
        }
    }

    private func headerCell() -> UITableViewCell {
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

    private func confirmationCell() -> UITableViewCell {
        return UITableViewCell()
    }

    private func etherTransactionFeeCell() -> UITableViewCell {
        let balance = self.balance(of: tx.amountTokenData)
        let resultingBalance = balance - tx.amountTokenData.balance! - tx.feeTokenData.balance!
        return feeCell(currentBalance: tx.amountTokenData.withBalance(balance),
                       transactionFee: tx.feeTokenData,
                       resultingBalance: tx.amountTokenData.withBalance(resultingBalance))
    }


    private func tokenBalanceChangeCell() -> UITableViewCell {
        let balance = self.balance(of: tx.amountTokenData)
        let resultingBalance = balance - tx.amountTokenData.balance!
        return feeCell(currentBalance: tx.amountTokenData.withBalance(balance),
                       transactionFee: nil,
                       resultingBalance: tx.amountTokenData.withBalance(resultingBalance))
    }

    private func etherFeeBalanceChangeCell() -> UITableViewCell {
        let balance = self.balance(of: tx.feeTokenData)
        let resultingBalance = balance - tx.feeTokenData.balance!
        return feeCell(currentBalance: nil,
                       transactionFee: tx.feeTokenData,
                       resultingBalance: tx.feeTokenData.withBalance(resultingBalance))
    }

    private func balance(of token: TokenData) -> BigInt {
        return ApplicationServiceRegistry.walletService.accountBalance(tokenID: BaseID(token.address))!
    }

    private func feeCell(currentBalance: TokenData?,
                         transactionFee: TokenData?,
                         resultingBalance: TokenData) -> UITableViewCell {
        let cell = TransactionFeeCell(frame: .zero)
        cell.transactionFeeView.configure(currentBalance: currentBalance,
                                          transactionFee: transactionFee,
                                          resultingBalance: resultingBalance)
        return cell
    }

}
