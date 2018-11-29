//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common
import BigInt

protocol ReviewTransactionViewControllerDelegate: class {
    func wantsToSubmitTransaction(_ completion: @escaping (_ allowed: Bool) -> Void)
    func didFinish() // TODO: rename
}

final class ReviewTransactionViewController: UITableViewController {

    private(set) var tx: TransactionData!
    private(set) weak var delegate: ReviewTransactionViewControllerDelegate!

    private var cells = [IndexPath: UITableViewCell]()

    private var isConfirmationRequired: Bool {
        return ApplicationServiceRegistry.walletService.ownerAddress(of: .browserExtension) != nil
    }
    internal let confirmationCell = TransactionConfirmationCell()

    private let scheduler = OneOperationWaitingScheduler(interval: 30)

    private class IndexPathIterator {

        private var index: Int = 0

        func next() -> IndexPath {
            defer { index += 1 }
            return IndexPath(row: index, section: 0)
        }

    }

    enum Strings {
        static let outgoingTransfer = LocalizedString("transaction.outgoing_transfer", comment: "Outgoing transafer")
        static let submit = LocalizedString("transaction.submit", comment: "Submit transaction")
        static let title = LocalizedString("transaction.review_title", comment: "Review transaction title")

        enum Alert {
            static let title = LocalizedString("transaction_confirmation_alert.title",
                                               comment: "Title for transaction confirmation alert.")
            static let description = LocalizedString("transaction_confirmation_alert.description",
                                                     comment: "Description for transaction confirmation alert.")
            static let resend = LocalizedString("transaction_confirmation_alert.resend",
                                                comment: "Resend button.")
            static let cancel = LocalizedString("transaction_confirmation_alert.cancel",
                                                comment: "Cancel button.")
        }
    }

    convenience init(transactionID: String, delegate: ReviewTransactionViewControllerDelegate) {
        self.init()
        tx = ApplicationServiceRegistry.walletService.transactionData(transactionID)!
        self.delegate = delegate
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: Strings.submit, style: .done, target: self, action: #selector(submit))
        configureTableView()
        createCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestSignatures()
    }

    private func configureTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundView = BackgroundImageView(frame: tableView.frame)
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath]!
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isConfirmationRequired && cells[indexPath] is TransactionConfirmationCell {
            return 0
        }
        return UITableView.automaticDimension
    }

    // MARK: - Table view cell creation

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
        guard tx.id == self.tx.id else { return }
        self.tx = tx
        updateConfirmationCell(with: tx.status)
    }

    private func updateConfirmationCell(with status: TransactionData.Status) {
        switch status {
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

    // MARK: - Requesting signatures

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
        DispatchQueue.global().async { [weak self] in
            do {
                try self?.doAction(action)
            } catch let error {
                DispatchQueue.main.sync {
                    ErrorHandler.showError(message: error.localizedDescription,
                                           log: "operation failed: \(error)",
                                           error: nil)
                }
            }
        }
    }

    private func doAction(_ action: @escaping () throws -> TransactionData) throws {
        self.tx = try action()
        DispatchQueue.main.sync {
            switch self.tx.status {
            case .success, .pending, .failed, .discarded:
                self.delegate.didFinish()
            default:
                self.updateConfirmationCell(with: self.tx.status)
            }
        }
    }

    // MARK: - Submitting transaction

    @objc internal func submit() {
        guard tx.status == .readyToSubmit else {
            showTransactionNeedsConfirmationAlert()
            return
        }
        delegate.wantsToSubmitTransaction { [unowned self] allowed in
            if allowed { self.doSubmit() }
        }
    }

    private func showTransactionNeedsConfirmationAlert() {
        let alert = UIAlertController(title: Strings.Alert.title,
                                      message: Strings.Alert.description,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.Alert.resend, style: .default) { [unowned self] _ in
            self.requestSignatures()
        })
        alert.addAction(UIAlertAction(title: Strings.Alert.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func doSubmit() {
        performTransactionAction { [unowned self] in
            try ApplicationServiceRegistry.walletService.submitTransaction(self.tx.id)
        }
    }

}
