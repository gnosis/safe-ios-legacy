//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common
import MultisigWalletApplication

public protocol ReviewRecoveryTransactionViewControllerDelegate: class {

    func reviewRecoveryTransactionViewControllerDidCancel()
    func reviewRecoveryTransactionViewControllerDidSubmit()

}

public class ReviewRecoveryTransactionViewController: UIViewController {

    private enum Strings {

        static let title = LocalizedString("recover_safe_title",
                                           comment: "Header of the review transaction screen")
        static let cancel = LocalizedString("cancel", comment: "Cancel")
        static let submit = LocalizedString("submit", comment: "Submit")

    }

    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet var submitButtonItem: UIBarButtonItem!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var addressLabel: FullEthereumAddressLabel!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var transactionFeeView: TransactionFeeView!
    var headerStyle = HeaderStyle.contentHeader

    public weak var delegate: ReviewRecoveryTransactionViewControllerDelegate?
    private var isUpdateDisabled: Bool = false
    var activityIndicator = UIActivityIndicatorView(style: .gray)
    var activityButtonItem: UIBarButtonItem!


    public var safeAddress: String? {
        didSet {
            update()
        }
    }

    public var feeBalance: TokenData? {
        didSet {
            update()
        }
    }

    public var feeAmount: TokenData? {
        didSet {
            update()
        }
    }

    public var resultingBalance: TokenData? {
        didSet {
            update()
        }
    }

    var isReadyToSubmit: Bool = false {
        didSet {
            update()
        }
    }

    var recoveryTransaction: TransactionData? {
        didSet {
            isUpdateDisabled = true
            guard let tx = recoveryTransaction else {
                isReadyToSubmit = false
                resultingBalance = nil
                feeAmount = nil
                feeBalance = nil
                safeAddress = nil
                isUpdateDisabled = false
                update()
                return
            }
            safeAddress = tx.sender
            let balance = (ApplicationServiceRegistry
                .walletService.accountBalance(tokenID: BaseID(tx.feeTokenData.address)) ?? 0)
            feeBalance = tx.feeTokenData.withBalance(balance)
            feeAmount = tx.feeTokenData
            resultingBalance = tx.feeTokenData.withBalance(balance - abs(tx.feeTokenData.balance ?? 0))
            isReadyToSubmit = ApplicationServiceRegistry.recoveryService.isRecoveryTransactionReadyToSubmit()
            isUpdateDisabled = false
            update()
        }
    }

    public static func create(delegate: ReviewRecoveryTransactionViewControllerDelegate?)
        -> ReviewRecoveryTransactionViewController {
            let controller = StoryboardScene.RecoverSafe.reviewRecoveryTransactionViewController.instantiate()
            controller.delegate = delegate
            return controller
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        cancelButtonItem.title = Strings.cancel
        submitButtonItem.title = Strings.submit
        activityButtonItem = UIBarButtonItem(customView: activityIndicator)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.attributedText = .header(from: Strings.title, style: headerStyle)
        update()
        start()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(RecoverSafeTrackingEvent.review)
    }

    func reloadData() {
        let tx = ApplicationServiceRegistry.recoveryService.recoveryTransaction()
        DispatchQueue.main.async {
            self.recoveryTransaction = tx
            self.stopActivityIndicator()
        }
    }

    func update() {
        guard isViewLoaded && !isUpdateDisabled else { return }
        identiconView.seed = safeAddress ?? ""
        identiconView.isHidden = safeAddress == nil
        addressLabel.address = safeAddress
        submitButtonItem.isEnabled = isReadyToSubmit
        transactionFeeView.configure(currentBalance: feeBalance,
                                     transactionFee: feeAmount,
                                     resultingBalance: resultingBalance)
    }

    func startActivityIndicator() {
        activityIndicator.startAnimating()
        navigationItem.setRightBarButton(activityButtonItem, animated: true)
    }

    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        if navigationItem.rightBarButtonItem != submitButtonItem {
            navigationItem.setRightBarButton(submitButtonItem, animated: true)
        }
    }

    func start() {
        startActivityIndicator()
        DispatchQueue.global().async {
            ApplicationServiceRegistry.recoveryService
                .createRecoveryTransaction(subscriber: self) { [weak self] error in
                    guard let `self` = self else { return }
                    DispatchQueue.main.async {
                        self.stopActivityIndicator()
                        self.show(error: error)
                    }
            }
            ApplicationServiceRegistry.recoveryService.observeBalance(subscriber: self)
        }
    }

    func show(error: Error) {
        let message = error.localizedDescription
        let controller = RecoveryFailedAlertController.create(message: message) { [unowned self] in
            self.delegate?.reviewRecoveryTransactionViewControllerDidCancel()
        }
        present(controller, animated: true)
    }

    @IBAction func cancel(_ sender: Any) {
        DispatchQueue.global().async {
            ApplicationServiceRegistry.recoveryService.cancelRecovery()
        }
        delegate?.reviewRecoveryTransactionViewControllerDidCancel()
    }

    @IBAction func submit(_ sender: Any) {
        guard recoveryTransaction != nil else { return }
        delegate?.reviewRecoveryTransactionViewControllerDidSubmit()
    }

    // TODO: remove duplication
    @objc func showTransactionFeeInfo() {
        let alert = UIAlertController(title: LocalizedString("transaction_fee", comment: "Network fee"),
                                      message: LocalizedString("transaction_fee_explanation",
                                                               comment: "Explanatory message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString("close", comment: "Close"), style: .default))
        present(alert, animated: true, completion: nil)
    }
}

extension ReviewRecoveryTransactionViewController: EventSubscriber {

    public func notify() {
        reloadData()
    }

}

class RecoveryFailedAlertController: SafeAlertController {

    private enum Strings {

        static let title = LocalizedString("error", comment: "Recovery transaction failed alert's title")
        static let okTitle = LocalizedString("ok", comment: "OK button title")

    }

    static func create(message: String,
                       ok: @escaping () -> Void) -> RecoveryFailedAlertController {
        let controller = RecoveryFailedAlertController(title: Strings.title,
                                                       message: message,
                                                       preferredStyle: .alert)
        let okAction = UIAlertAction.create(title: Strings.okTitle, style: .cancel, handler: wrap(closure: ok))
        controller.addAction(okAction)
        return controller
    }

}
