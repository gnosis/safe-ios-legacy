//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import BigInt
import Common

protocol TransactionReviewViewControllerDelegate: class {
    func transactionReviewViewControllerWantsToSubmitTransaction(completionHandler: @escaping (Bool) -> Void)
    func transactionReviewViewControllerDidFinish()
}

final class TransactionReviewViewController: UIViewController {

    @IBOutlet weak var senderView: TransactionParticipantView!
    @IBOutlet weak var recipientView: TransactionParticipantView!
    @IBOutlet weak var transactionValueView: TransactionValueView!

    @IBOutlet weak var safeBalanceTitleLabel: UILabel!
    @IBOutlet weak var safeBalanceValueLabel: UILabel!

    @IBOutlet weak var feeTitleLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!

    @IBOutlet weak var dataInfoStackView: UIStackView!
    @IBOutlet weak var dataTitleLabel: UILabel!
    @IBOutlet weak var dataValueLabel: UILabel!

    @IBOutlet weak var actionTitleLabel: UILabel!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var actionDescription: UILabel!
    @IBOutlet weak var actionButtonInfoLabel: UILabel!
    @IBOutlet weak var actionButton: BorderedButton!

    var transactionID: String!
    weak var delegate: TransactionReviewViewControllerDelegate?

    private var didNotRequestSignaturesYet = true
    private var tokenFormatter: TokenNumberFormatter!
    private var feeFormatter: TokenNumberFormatter!

    static func create() -> TransactionReviewViewController {
        return StoryboardScene.Main.transactionReviewViewController.instantiate()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        senderView.name = Strings.senderName
        recipientView.name = Strings.recipientName
        transactionValueView.isSingleValue = true
        safeBalanceTitleLabel.text = Strings.balanceTitle
        feeTitleLabel.text = Strings.feeTitle
        dataTitleLabel.text = Strings.dataTitle
        dataInfoStackView.isHidden = true
        actionButtonInfoLabel.isHidden = true
        update()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resumeAnimation),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    @objc private func resumeAnimation() {
        progressView.resumeAnimation()
    }

    func update() {
        guard isViewLoaded else { return }
        let tx = ApplicationServiceRegistry.walletService.transactionData(transactionID)!
        update(tx)
        if (tx.status == .waitingForConfirmation || tx.status == .readyToSubmit) && didNotRequestSignaturesYet {
            requestSignatures()
            didNotRequestSignaturesYet = false
        }
    }

    private func update(_ tx: TransactionData) {
        senderView.address = tx.sender
        recipientView.address = tx.recipient
        tokenFormatter = TokenNumberFormatter.ERC20Token(code: tx.token, decimals: tx.tokenDecimals)
        transactionValueView.tokenAmount = tokenFormatter.string(from: tx.amount)

        feeFormatter = TokenNumberFormatter.ERC20Token(code: tx.feeToken, decimals: tx.feeTokenDecimals)
        let balance = ApplicationServiceRegistry.walletService.accountBalance(tokenID: ethID)!
        safeBalanceValueLabel.text = feeFormatter.string(from: BigInt(balance))
        feeValueLabel.text = feeFormatter.string(from: -tx.fee)

        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        progressView.stopAnimating()

        switch tx.status {
        case .waitingForConfirmation:
            progressView.beginAnimating()
            updateActionTitle(with: Strings.Status.waiting)
            actionButton.addTarget(self, action: #selector(requestSignatures), for: .touchUpInside)
        case .rejected:
            progressView.isError = true
            updateActionTitle(with: Strings.Status.rejected)
        case .readyToSubmit:
            progressView.isError = false
            progressView.isIndeterminate = false
            progressView.progress = 1.0
            updateActionTitle(with: Strings.Status.readyToSubmit)
            actionButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        case .pending, .failed, .success, .discarded:
            delegate?.transactionReviewViewControllerDidFinish()
        }
    }

    private func updateActionTitle(with status: Strings.Status) {
        actionTitleLabel.text = status.title
        actionDescription.text = status.description
        if status.action == nil {
            actionButton.isHidden = true
        } else {
            actionButton.setTitle(status.action, for: .normal)
        }
    }


    @objc private func requestSignatures() {
        performAction { [unowned self] in
            try ApplicationServiceRegistry.walletService.requestTransactionConfirmation(self.transactionID)
        }
    }

    @objc private func submit() {
        if let delegate = delegate {
            delegate.transactionReviewViewControllerWantsToSubmitTransaction { [weak self] shouldSubmit in
                if shouldSubmit {
                    self?.doSubmit()
                }
            }
        } else {
            doSubmit()
        }
    }

    private func doSubmit() {
        performAction { [unowned self] in
            try ApplicationServiceRegistry.walletService.submitTransaction(self.transactionID)
        }
    }

    private func performAction(_ action: @escaping () throws -> TransactionData) {
        actionButton.isEnabled = false
        DispatchQueue.global().async {
            do {
                let tx = try action()
                DispatchQueue.main.sync {
                    self.actionButton.isEnabled = true
                    self.update(tx)
                }
            } catch let error {
                DispatchQueue.main.sync {
                    self.actionButton.isEnabled = true
                    ErrorHandler.showError(message: error.localizedDescription,
                                           log: "operation failed: \(error)",
                                           error: nil)
                }
            }
        }
    }

    struct Strings {

        static let senderName = LocalizedString("transaction.sender.name", comment: "Sender")
        static let recipientName = LocalizedString("transaction.recipient.name", comment: "Recipient")
        static let balanceTitle = LocalizedString("transaction.balance.title", comment: "Safe balance")
        static let feeTitle = LocalizedString("transaction.fee.title", comment: "Maximum transaction fee")
        static let dataTitle = LocalizedString("transaction.data.title", comment: "Data included")

        struct Status {

            var title: String?
            var description: String?
            var action: String?

            static let waiting = Status(title: LocalizedString("transaction.status.waiting.title",
                                                               comment: "AWAITING CONFIRMATION"),
                                        description:
                LocalizedString("transaction.status.waiting.description",
                                comment: "Confirm this transaction with the browser extension"),
                                        action: LocalizedString("transaction.status.actionTitle.resend",
                                                                comment: "Re-send confirmation request"))

            static let rejected = Status(title: LocalizedString("transaction.status.rejected.title",
                                                                comment: "REJECTED BY EXTENSION"),
                                         description:
                LocalizedString("transaction.status.rejected.description",
                                comment: "Transaction was rejected by the browser extension."),
                                         action: nil)
            static let readyToSubmit = Status(title: LocalizedString("transaction.status.readyToSubmit.title",
                                                                     comment: "CONFIRMED"),
                                              description:
                LocalizedString("transaction.status.readyToSubmit.description",
                                comment: "Transaction was confirmed by the browser extension. You can submit it now."),
                                              action: LocalizedString("transaction.status.actionTitle.submit",
                                                                      comment: "Submit"))

        }

    }

}
