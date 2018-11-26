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

    private var isConfirmationRequired: Bool {
        return ApplicationServiceRegistry.walletService.ownerAddress(of: .browserExtension) != nil
    }

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

    // MARK: - table view delegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isConfirmationRequired && cells[indexPath] is TransactionConfirmationCell {
            return 0
        }
        return UITableView.automaticDimension
    }

    // MARK: Table view cell creation

    private func createCells() {
        var row: Int = 0
        cells[IndexPath(row: next(&row), section: 0)] = headerCell()
        cells[IndexPath(row: next(&row), section: 0)] = transferViewCell()
        if tx.amountTokenData.isEther {
           cells[IndexPath(row: next(&row), section: 0)] = etherTransactionFeeCell()
        } else {
            cells[IndexPath(row: next(&row), section: 0)] = tokenBalanceChangeCell()
            cells[IndexPath(row: next(&row), section: 0)] = etherFeeBalanceChangeCell()
        }
        cells[IndexPath(row: next(&row), section: 0)] = confirmationCell()
    }

    private func next(_ index: inout Int) -> Int {
        index += 1
        return index - 1
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

    private func confirmationCell() -> TransactionConfirmationCell {
        return TransactionConfirmationCell()
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
