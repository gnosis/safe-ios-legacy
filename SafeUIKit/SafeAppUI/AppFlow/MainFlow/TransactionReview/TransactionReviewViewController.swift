//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import BigInt

public class TransactionReviewViewController: UIViewController {

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

    private let tokenFormatter = TokenNumberFormatter()

    public static func create() -> TransactionReviewViewController {
        return StoryboardScene.Main.transactionReviewViewController.instantiate()
    }

    private func update(_ tx: TransactionData) {
        guard isViewLoaded else { return }
        senderView.address = tx.sender
        recipientView.address = tx.recipient
        transactionValueView.tokenAmount = tokenFormatter.string(from: tx.amount)
        let balance = ApplicationServiceRegistry.walletService.accountBalance(token: "ETH")!
        safeBalanceValueLabel.text = tokenFormatter.string(from: BigInt(balance))
        feeValueLabel.text = tokenFormatter.string(from: -tx.fee)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tokenFormatter.decimals = 18
        tokenFormatter.tokenCode = "ETH"

        progressView.beginAnimating()

        senderView.name = Strings.senderName
        recipientView.name = Strings.recipientName
        transactionValueView.isSingleValue = true
        safeBalanceTitleLabel.text = Strings.balanceTitle
        feeTitleLabel.text = Strings.feeTitle
        dataTitleLabel.text = Strings.dataTitle
        dataInfoStackView.isHidden = true
        actionTitleLabel.text = Strings.Status.Waiting.title
        actionDescription.text = Strings.Status.Waiting.description
        actionButtonInfoLabel.text = Strings.Status.Waiting.info
        actionButtonInfoLabel.isHidden = true
        actionButton.setTitle(Strings.Status.Waiting.action, for: .normal)

        actionButton.addTarget(self, action: #selector(performAction), for: .touchUpInside)

        update()
        requestSignatures()
    }

    @objc func performAction(_ sender: Any) {
        requestSignatures()
    }

    func update() {
        let tx = ApplicationServiceRegistry.walletService.transactionData(transactionID)!
        update(tx)
    }

    private func requestSignatures() {
        DispatchQueue.global().async {
            do {
                let tx = try ApplicationServiceRegistry.walletService.requestTransactionConfirmation(self.transactionID)
                DispatchQueue.main.sync {
                    self.update(tx)
                }
            } catch let error {
                DispatchQueue.main.sync {
                    ErrorHandler.showError(message: error.localizedDescription,
                                           log: "request confirmation failed: \(error)",
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

            struct Waiting {
                static let title = LocalizedString("transaction.status.waiting.title",
                                                   comment: "AWAITING CONFIRMATION")
                static let description = LocalizedString("transaction.status.waiting.description",
                                                         comment: "Confirm this transaction with the browser extension")
                static let info = LocalizedString("transaction.status.waiting.info",
                                                  comment: "wait 0:30s before re-sending request")
                static let action = LocalizedString("transaction.status.waiting.actionTitle",
                                                    comment: "Re-send confirmation request")

            }

        }

    }

}
