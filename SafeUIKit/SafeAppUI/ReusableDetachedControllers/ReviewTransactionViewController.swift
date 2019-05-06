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
    internal let confirmationCell = TransactionConfirmationCell()

    var hasBrowserExtension: Bool {
        return ApplicationServiceRegistry.walletService.ownerAddress(of: .browserExtension) != nil
    }

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
            guard oldValue != hasUpdatedFee else { return }
            DispatchQueue.main.async {
                self.updateSubmitButton()
                self.updateEtherFeeBalanceCell()
            }
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

        // Otherwise header cell height is smaller than the content height
        // Alternatives tried: setting cell size when creating the header cell
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    private var didRequestSignatures: Bool = false
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didRequestSignatures else { return }
        requestSignatures()
        didRequestSignatures = true
    }

    private func configureTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        view.setNeedsUpdateConstraints()
    }

    private func disableSubmit() {
        submitButtonItem.isEnabled = false
        navigationItem.hidesBackButton = true
    }

    private func enableSubmit() {
        submitButtonItem.isEnabled = true
        navigationItem.hidesBackButton = false
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
        if !hasBrowserExtension && cells[indexPath] is TransactionConfirmationCell {
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
        DispatchQueue.main.async {
            self.updateConfirmationCell()
            self.updateSubmitButton()
        }
    }

    private func updateConfirmationCell() {
        precondition(Thread.isMainThread)
        switch tx.status {
        case .waitingForConfirmation:
            confirmationCell.transactionConfirmationView.status = .pending
        case .readyToSubmit:
            confirmationCell.transactionConfirmationView.status = .confirmed
            didConfirm()
        case .rejected:
            confirmationCell.transactionConfirmationView.status = .rejected
            didReject()
        default:
            confirmationCell.transactionConfirmationView.status = .undefined
        }
    }

    func didConfirm() {
        // override in subclass
    }

    func didReject() {
        // override in subclass
    }

    private func updateSubmitButton() {
        precondition(Thread.isMainThread)
        if self.hasUpdatedFee && self.tx.status != .rejected {
            self.enableSubmit()
        } else {
            self.disableSubmit()
        }
    }

    internal func updateEtherFeeBalanceCell() {
        precondition(Thread.isMainThread)
        cells[feeCellIndexPath] = etherTransactionFeeCell()
        if feeCellIndexPath.row < tableView.numberOfRows(inSection: feeCellIndexPath.section) {
            tableView.reloadRows(at: [feeCellIndexPath], with: .none)
        }
    }

    // MARK: - Requesting signatures

    private func requestSignatures() {
        scheduler.schedule { [weak self] in
            self?.doRequest()
        }
    }

    private func doRequest() {
        performTransactionConfirmationsRequestAction { [unowned self] in
            try ApplicationServiceRegistry.walletService.requestTransactionConfirmationIfNeeded(self.tx.id)
        }
    }

    private func performTransactionConfirmationsRequestAction(_ action: @escaping () throws -> TransactionData) {
        disableSubmit()
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            do {
                self.tx = try ApplicationServiceRegistry.walletService.estimateTransactionIfNeeded(self.tx.id)
                self.hasUpdatedFee = true
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
            switch self.tx.status {
            case .success, .pending, .failed, .discarded:
                didSubmit()
                self.delegate.didFinishReview()
            default:
                self.updateConfirmationCell()
            }
        }
    }

    func didSubmit() {
        // override in subclass
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

    @objc func showTransactionFeeInfo() {
        present(TransactionFeeAlertController.create(), animated: true, completion: nil)
    }

}

extension ReviewTransactionViewController {

    // MARK: - Localization

    enum Strings {

        static let outgoingTransfer = LocalizedString("transaction_type_asset_transfer", comment: "Outgoing transafer")
        static let submit = LocalizedString("submit", comment: "Submit transaction")
        static let title = LocalizedString("review", comment: "Review transaction title")

        enum Alert {
            static let title = LocalizedString("open_browser_extension",
                                               comment: "Title for transaction confirmation alert.")
            static let description = LocalizedString("resend_to_refresh",
                                                     comment: "Description for transaction confirmation alert.")
            static let resend = LocalizedString("resend",
                                                comment: "Resend button.")
            static let cancel = LocalizedString("cancel",
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
