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
    internal let confirmationCell = TransactionConfirmationCell()

    private let scheduler = OneOperationWaitinScheduler(interval: 30)

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
        requestSignatures()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConfirmationCell(tx)
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
        cells = [IndexPath: UITableViewCell]()
        let indexPath = IndexPathIterator()
        cells[indexPath.next()] = headerCell()
        cells[indexPath.next()] = transferViewCell()
        if tx.amountTokenData.isEther {
           cells[indexPath.next()] = etherTransactionFeeCell()
        } else {
            cells[indexPath.next()] = tokenBalanceChangeCell()
            cells[indexPath.next()] = etherFeeBalanceChangeCell()
        }
        cells[indexPath.next()] = confirmationCell
    }

    private class IndexPathIterator {

        private var index: Int = 0

        func next() -> IndexPath {
            defer { index += 1 }
            return IndexPath(row: index, section: 0)
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

    internal func update(with tx: TransactionData) {
        self.tx = tx
        createCells()
        tableView.reloadData()
    }

    private func updateConfirmationCell(_ tx: TransactionData) {
        switch tx.status {
        case .waitingForConfirmation:
            confirmationCell.transactionConfirmationView.status = .pending
        case .readyToSubmit:
            confirmationCell.transactionConfirmationView.status = .confirmed
        case .rejected:
            confirmationCell.transactionConfirmationView.status = .rejected
        default:
            confirmationCell.transactionConfirmationView.status = .undefined
        }
    }

    // - MARK: Requesting signatures

    private func requestSignatures() {
        scheduler.schedule { [weak self] in
            self?.doRequest()
        }
    }

    private func doRequest() {
        performTransactionAction { [unowned self] in
            try ApplicationServiceRegistry.walletService.requestTransactionConfirmation(self.tx.id)
        }
    }

    private func performTransactionAction(_ action: @escaping () throws -> TransactionData) {
        DispatchQueue.global().async {
            do {
                let tx = try action()
                DispatchQueue.main.sync {
                    self.updateConfirmationCell(tx)
                }
            } catch let error {
                DispatchQueue.main.sync {
                    ErrorHandler.showError(message: error.localizedDescription,
                                           log: "operation failed: \(error)",
                                           error: nil)
                }
            }
        }
    }

}
