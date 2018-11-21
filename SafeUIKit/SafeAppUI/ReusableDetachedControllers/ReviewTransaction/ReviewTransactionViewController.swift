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
        dequeueCellsOnce()
    }

    private func configureTableView() {
        tableView.register(TransactionHeaderCell.self, forCellReuseIdentifier: "TransactionHeaderCell")
        tableView.register(TransferViewCell.self, forCellReuseIdentifier: "TransferViewCell")
        tableView.register(TransactionFeeCell.self, forCellReuseIdentifier: "TransactionFeeCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundView = BackgroundImageView(frame: tableView.frame)
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
    }

    private func dequeueCellsOnce() {
        addHeaderCell(for: IndexPath(row: 0, section: 0))
        addTransferViewCell(for: IndexPath(row: 1, section: 0))
        addConfirmationCell(for: IndexPath(row: 2, section: 0))
        if tx.amountTokenData.isEther {
            addTransactionFeeCellForEther(for: IndexPath(row: 3, section: 0))
        } else {
            addTransactionFeeCellForTokenTransfer_inToken(for: IndexPath(row: 3, section: 0))
            addTransactionFeeCellForTokenTransfer_inEther(for: IndexPath(row: 4, section: 0))
        }
    }

    private func addHeaderCell(for indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHeaderCell",
                                                 for: indexPath) as! TransactionHeaderCell
        cell.configure(imageURL: tx.amountTokenData.logoURL,
                       code: tx.amountTokenData.code,
                       info: Strings.outgoingTransfer)
        cells[indexPath] = cell
    }

    private func addTransferViewCell(for indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransferViewCell",
                                                 for: indexPath) as! TransferViewCell
        cell.transferView.fromAddress = tx.sender
        cell.transferView.toAddress = tx.recipient
        cell.transferView.tokenData = tx.amountTokenData
        cells[indexPath] = cell
    }

    private func addConfirmationCell(for indexPath: IndexPath) {
        cells[indexPath] = UITableViewCell()
    }

    private func addTransactionFeeCellForEther(for indexPath: IndexPath) {
        let (cell, currentBalance) = cellAndCurrentBalance(for: indexPath)
        let currentBalanceTokenData = tx.amountTokenData.copy(balance: currentBalance)
        let resultingBalance =
            tx.amountTokenData.copy(balance: currentBalance - tx.amountTokenData.balance! - tx.feeTokenData.balance!)
        cell.transactionFeeView.configure(currentBalance: currentBalanceTokenData,
                                          transactionFee: tx.feeTokenData,
                                          resultingBalance: resultingBalance)
        cells[indexPath] = cell
    }

    private func addTransactionFeeCellForTokenTransfer_inToken(for indexPath: IndexPath) {
        let (cell, currentBalance) = cellAndCurrentBalance(for: indexPath)
        let currentBalanceTokenData = tx.amountTokenData.copy(balance: currentBalance)
        let resultingBalance = tx.amountTokenData.copy(balance: currentBalance - tx.amountTokenData.balance!)
        cell.transactionFeeView.configure(currentBalance: currentBalanceTokenData,
                                          transactionFee: nil,
                                          resultingBalance: resultingBalance)
        cells[indexPath] = cell
    }

    private func addTransactionFeeCellForTokenTransfer_inEther(for indexPath: IndexPath) {
        let (cell, currentBalance) = cellAndCurrentBalance(for: indexPath, forFee: true)
        let resultingBalance = tx.feeTokenData.copy(balance: currentBalance - tx.feeTokenData.balance!)
        cell.transactionFeeView.configure(currentBalance: nil,
                                          transactionFee: tx.feeTokenData,
                                          resultingBalance: resultingBalance)
        cells[indexPath] = cell
    }

    private func cellAndCurrentBalance(for indexPath: IndexPath, forFee: Bool = false) -> (TransactionFeeCell, BigInt) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionFeeCell",
                                                 for: indexPath) as! TransactionFeeCell
        let address = forFee ? tx.feeTokenData.address : tx.amountTokenData.address
        let currentBalance = ApplicationServiceRegistry.walletService.accountBalance(tokenID: BaseID(address))!
        return (cell, currentBalance)
    }

    // MARK: - table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath]!
    }

}
