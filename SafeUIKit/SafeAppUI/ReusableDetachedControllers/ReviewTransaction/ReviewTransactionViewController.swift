//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common
import BigInt

public protocol ReviewTransactionViewControllerDelegate: class {
    func wantsToSubmitTransaction(_ completion: @escaping (_ allowed: Bool) -> Void)
    func didFinishReview()
}

public class ReviewTransactionViewController: UITableViewController {

    private(set) var tx: TransactionData!
    private(set) weak var delegate: ReviewTransactionViewControllerDelegate!

    internal var cells = [IndexPath: UITableViewCell]()

    /// Confirmation cell is always last if present
    private var isConfirmationRequired: Bool {
        return ApplicationServiceRegistry.walletService.ownerAddress(of: .browserExtension) != nil
    }
    internal let confirmationCell = TransactionConfirmationCell()

    /// To control how frequent a user can send confirmation requests
    private let scheduler = OneOperationWaitingScheduler(interval: 30)
    private var submitButtonItem: UIBarButtonItem!

    internal class IndexPathIterator {
        private var index: Int = 0
        func next() -> IndexPath {
            defer { index += 1 }
            return IndexPath(row: index, section: 0)
        }
    }

    internal var feeCellIndexPath: IndexPath!
    private var hasUpdatedFee: Bool = false {
        didSet {
            updateSubmitButton()
        }
    }

    public convenience init(transactionID: String, delegate: ReviewTransactionViewControllerDelegate) {
        self.init()
        tx = ApplicationServiceRegistry.walletService.transactionData(transactionID)!
        self.delegate = delegate
        submitButtonItem = UIBarButtonItem(title: Strings.submit, style: .done, target: self, action: #selector(submit))
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        navigationItem.rightBarButtonItem = submitButtonItem
        disableSubmit()
        configureTableView()
        createCells()
        updateSubmitButton()
    }

    private var didRequestSignatures: Bool = false
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didRequestSignatures else { return }
        requestSignatures()
        didRequestSignatures = true
    }

    private func configureTableView() {
        let backgroundView = BackgroundImageView(frame: tableView.frame)
        tableView.separatorStyle = .none
        tableView.backgroundView = backgroundView
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        let stickyHeader = UIView()
        stickyHeader.translatesAutoresizingMaskIntoConstraints = false
        stickyHeader.backgroundColor = .white
        backgroundView.addSubview(stickyHeader)
        NSLayoutConstraint.activate([
            stickyHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stickyHeader.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stickyHeader.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stickyHeader.bottomAnchor.constraint(equalTo: tableView.topAnchor)])
        view.setNeedsUpdateConstraints()
    }

    private func disableSubmit() {
        submitButtonItem.isEnabled = false
    }

    private func enableSubmit() {
        submitButtonItem.isEnabled = true
    }

    // MARK: - Table view data source

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.keys.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath]!
    }

    // MARK: - Table view delegate

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isConfirmationRequired && cells[indexPath] is TransactionConfirmationCell {
            return 0
        }
        return UITableView.automaticDimension
    }

    // MARK: - Table view cell creation

    internal func createCells() {
        assertionFailure("Should be overriden")
    }

    /// called when signing results are received
    internal func update(with tx: TransactionData) {
        self.tx = tx
        updateConfirmationCell()
        updateSubmitButton()
    }

    private func updateConfirmationCell() {
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

    private func updateSubmitButton() {
        DispatchQueue.main.async {
            if self.hasUpdatedFee && self.tx.status != .rejected {
                self.enableSubmit()
            } else {
                self.disableSubmit()
            }
        }
    }

    // MARK: - Requesting signatures

    private func requestSignatures() {
        scheduler.schedule { [weak self] in
            self?.doRequest()
        }
    }

    private func doRequest() {
        hasUpdatedFee = false
        performTransactionConfirmationsRequestAction { [unowned self] in
            try ApplicationServiceRegistry.walletService.requestTransactionConfirmationIfNeeded(self.tx.id)
        }
    }

    internal func updateEtherFeeBalanceCell() {
        cells[feeCellIndexPath] = etherTransactionFeeCell()
        if feeCellIndexPath.row < tableView.numberOfRows(inSection: feeCellIndexPath.section) {
            tableView.reloadRows(at: [feeCellIndexPath], with: .none)
        }
    }

    private func performTransactionConfirmationsRequestAction(_ action: @escaping () throws -> TransactionData) {
        disableSubmit()
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            do {
                try ApplicationServiceRegistry.walletService.estimateTransactionIfNeeded(self.tx.id)
                try self.doRequestConfirmationsAction(action)
            } catch let error {
                DispatchQueue.main.sync {
                    self.enableSubmit()
                    ErrorHandler.showError(message: error.localizedDescription,
                                           log: "operation failed: \(error)",
                                           error: nil)
                }
            }
        }
    }

    private func doRequestConfirmationsAction(_ action: @escaping () throws -> TransactionData) throws {
        self.tx = try action()
        DispatchQueue.main.sync {
            self.hasUpdatedFee = true
            switch self.tx.status {
            case .success, .pending, .failed, .discarded:
                self.delegate.didFinishReview()
            default:
                self.updateConfirmationCell()
                self.updateEtherFeeBalanceCell()
                self.updateSubmitButton()
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
        performTransactionConfirmationsRequestAction { [unowned self] in
            try ApplicationServiceRegistry.walletService.submitTransaction(self.tx.id)
        }
    }

    // TODO: remove duplication
    @objc func showTransactionFeeInfo() {
        let alert = UIAlertController(title: LocalizedString("transaction_fee_alert.title",
                                                             comment: "Transaction fee"),
                                      message: LocalizedString("transaction_fee_alert.message",
                                                               comment: "Explanatory message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString("transaction_fee_alert.ok",
                                                             comment: "Ok"), style: .default))
        present(alert, animated: true, completion: nil)
    }

}

extension ReviewTransactionViewController {

    // MARK: - Localization

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

    // MARK: - Cells

    internal func settingsCell(title: String, details: String) -> UITableViewCell {
        let cell = SettingsTransactionHeaderCell(frame: .zero)
        cell.headerView.fromAddress = tx.sender
        cell.headerView.titleText = title
        cell.headerView.detailText = details
        return cell
    }

    internal func etherTransactionFeeCell() -> UITableViewCell {
        let balance = self.balance(of: tx.amountTokenData)
        let resultingBalance = balance - abs(tx.amountTokenData.balance ?? 0) - abs(tx.feeTokenData.balance ?? 0)
        return feeCell(currentBalance: tx.amountTokenData.withBalance(balance),
                       transactionFee: tx.feeTokenData,
                       resultingBalance: tx.amountTokenData.withBalance(resultingBalance))
    }

    internal func balance(of token: TokenData) -> BigInt {
        return ApplicationServiceRegistry.walletService.accountBalance(tokenID: BaseID(token.address))!
    }

    internal func feeCell(currentBalance: TokenData?,
                          transactionFee: TokenData?,
                          resultingBalance: TokenData) -> UITableViewCell {
        let cell = TransactionFeeCell(frame: .zero)
        cell.transactionFeeView.configure(currentBalance: currentBalance,
                                          transactionFee: transactionFee,
                                          resultingBalance: resultingBalance)
        return cell
    }

}
