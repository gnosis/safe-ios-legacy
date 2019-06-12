//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common
import BigInt

// all delegate methods are called on the main thread.
public protocol ReviewTransactionViewControllerDelegate: class {
    func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                 completion: @escaping (_ allowed: Bool) -> Void)
    func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController)
}

public class ReviewTransactionViewController: UITableViewController {

    public var showsSubmitInNavigationBar: Bool = true

    let confirmationCell = TransactionConfirmationCell()
    var cells = [IndexPath: UITableViewCell]()
    var feeCellIndexPath: IndexPath!
    var submitButton: UIButton! {
        return confirmationCell.confirmationView.button
    }
    var isShowing2FA: Bool {
        return !confirmationCell.confirmationView.showsOnlyButton
    }
    var confirmationStatus: TransactionConfirmationView.Status {
        return confirmationCell.confirmationView.status
    }

    var hasBrowserExtension: Bool {
        return ApplicationServiceRegistry.walletService.ownerAddress(of: .browserExtension) != nil
    }

    private(set) var tx: TransactionData!
    private(set) weak var delegate: ReviewTransactionViewControllerDelegate!
    private var submitBarButton: UIBarButtonItem!
    /// To control how frequent a user can send confirmation requests
    private let scheduler = OneOperationWaitingScheduler(interval: 1)
    private var isLoading: Bool = false {
        didSet {
            updateLoading()
        }
    }

    public convenience init(transactionID: String, delegate: ReviewTransactionViewControllerDelegate) {
        self.init()
        tx = fetchTransaction(transactionID)
        self.delegate = delegate
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        submitBarButton = UIBarButtonItem(title: LocalizedString("submit", comment: "Submit transaction"),
                                          style: .done,
                                          target: self,
                                          action: #selector(submit))
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        configureTableView()
        createCells()

        if !hasBrowserExtension {
            confirmationCell.confirmationView.showsOnlyButton = true
        }
        if showsSubmitInNavigationBar {
            if let key = cells.first(where: { $0.value === confirmationCell })?.key {
                cells.removeValue(forKey: key)
            }
            navigationItem.rightBarButtonItem = submitBarButton
        }

        // Otherwise header cell height is smaller than the content height
        // Alternatives tried: setting cell size when creating the header cell
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    private func configureTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        view.setNeedsUpdateConstraints()
    }

    // MARK: - Table view

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.keys.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath]!
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    internal func createCells() {
        assertionFailure("Should be overriden")
    }

    // MARK: - Actions

    // overriden in subclass
    internal func fetchTransaction(_ id: String) -> TransactionData {
        return ApplicationServiceRegistry.walletService.transactionData(id)!
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestConfirmationsOnce()
    }

    private var didRequestConfirmationsBefore: Bool = false

    // overriden in subclass
    internal func requestConfirmationsOnce() {
        if didRequestConfirmationsBefore { return }
        didRequestConfirmationsBefore = true
        scheduleConfirmationRequest()
    }

    @objc internal func submit() {
        if tx.status == .rejected {
            ApplicationServiceRegistry.walletService.resetTransaction(tx.id)
            doRequest()
        } else if tx.status == .readyToSubmit {
            delegate.reviewTransactionViewControllerWantsToSubmitTransaction(self) { [unowned self] allowed in
                if allowed {
                    self.doSubmit()
                }
            }
        } else {
            showResendAlert(action: scheduleConfirmationRequest)
        }
    }

    /// Supposed to be called from flow coordinator when the screen is already shown, but new transaction data
    /// comes through incoming message.
    internal func update(with tx: TransactionData) {
        self.tx = tx
        DispatchQueue.main.async {
            self.reloadData()
            self.isLoading = false
        }
    }

    private func scheduleConfirmationRequest() {
        scheduler.schedule { [weak self] in
            DispatchQueue.main.async {
                self?.doRequest()
            }
        }
    }

    private func doRequest() {
        doAfterEstimateTransaction { [weak self] in
            guard let `self` = self else { return TransactionData.empty }
            return try ApplicationServiceRegistry.walletService.requestTransactionConfirmationIfNeeded(self.tx.id)
        }
    }

    private func doSubmit() {
        doAfterEstimateTransaction { [weak self] in
            guard let `self` = self else { return TransactionData.empty }
            return try ApplicationServiceRegistry.walletService.submitTransaction(self.tx.id)
        }
    }

    private func updateLoading() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async(execute: updateLoading)
            return
        }
        if isLoading {
            navigationItem.hidesBackButton = true
            submitButton?.isEnabled = false
            submitBarButton?.isEnabled = false
            navigationItem.titleView = LoadingTitleView()
        } else {
            navigationItem.hidesBackButton = false
            submitButton?.isEnabled = true
            submitBarButton?.isEnabled = true
            navigationItem.titleView = nil
        }
    }

    private func doAfterEstimateTransaction(_ action: @escaping () throws -> TransactionData) {
        precondition(Thread.isMainThread)
        isLoading = true
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            defer { self.isLoading = false }
            do {
                self.tx = try ApplicationServiceRegistry.walletService.estimateTransactionIfNeeded(self.tx.id)
                self.tx = try action()
                self.postProcessing()
            } catch {
                self.showError(error)
            }
        }
    }

    private func postProcessing() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async(execute: postProcessing)
            return
        }
        reloadData()
        notifyOfStatus()
    }

    private func showError(_ error: Error) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.showError(error) }
            return
        }
        ErrorHandler.showError(message: error.localizedDescription, log: "operation failed: \(error)", error: nil)
    }

    private func reloadData() {
        updateConfirmationCell()
        if feeCellIndexPath != nil {
            updateTransactionFeeCell()
        }
    }

    private func notifyOfStatus() {
        switch self.tx.status {
        case .readyToSubmit:
            self.didConfirm()
        case .rejected:
            self.didReject()
        case .success, .pending, .failed, .discarded:
            self.didSubmit()
            self.delegate.reviewTransactionViewControllerDidFinishReview(self)
        default: break
        }
    }

    func didSubmit() {
        // override in subclass
    }

    func didConfirm() {
        // override in subclass
    }

    func didReject() {
        // override in subclass
    }

    internal func updateTransactionFeeCell() {
        // override in subclass
    }

    private func updateConfirmationCell() {
        precondition(Thread.isMainThread)
        switch tx.status {
        case .waitingForConfirmation:
            confirmationCell.confirmationView.status = .pending
        case .readyToSubmit:
            confirmationCell.confirmationView.status = .confirmed
        case .rejected:
            confirmationCell.confirmationView.status = .rejected
        default:
            confirmationCell.confirmationView.status = .undefined
        }
    }

    @objc func showTransactionFeeInfo() {
        present(UIAlertController.networkFee(), animated: true, completion: nil)
    }

    private func showResendAlert(action: @escaping () -> Void) {
        let alert = UIAlertController(title: Alert.title, message: Alert.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alert.resend, style: .default) { _ in action() })
        alert.addAction(UIAlertAction(title: Alert.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Cells

    internal func settingsCell(title: String, details: String) -> UITableViewCell {
        let cell = SettingsTransactionHeaderCell(frame: .zero)
        cell.headerView.fromAddress = tx.sender
        cell.headerView.titleText = title
        cell.headerView.detailText = details
        return cell
    }

    internal func balance(of token: TokenData) -> BigInt? {
        return ApplicationServiceRegistry.walletService.accountBalance(tokenID: BaseID(token.address))
    }

    // MARK: - Other

    enum Strings {

        static let outgoingTransfer = LocalizedString("transaction_type_asset_transfer", comment: "Outgoing transafer")
        static let submit = LocalizedString("submit", comment: "Submit transaction")
        static let title = LocalizedString("review", comment: "Review transaction title")

    }

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

    internal class IndexPathIterator {
        private var index: Int = 0
        func next() -> IndexPath {
            defer { index += 1 }
            return IndexPath(row: index, section: 0)
        }
    }

}
