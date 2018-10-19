//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import DateTools
import MultisigWalletApplication
import SafeUIKit

public class TransactionDetailsViewController: UIViewController {

    struct Strings {
        static let type = LocalizedString("transaction.details.type", comment: "'Type' parameter name")
        static let submitted = LocalizedString("transaction.details.submitted",
                                               comment: "'Submitted' parameter name")
        static let status = LocalizedString("transaction.details.status", comment: "'Status' parameter name")
        static let fee = LocalizedString("transaction.details.fee", comment: "'Fee' parameter name")
        static let externalApp = LocalizedString("transaction.details.externalViewer",
                                                 comment: "'View on Etherscan' button name")
        static let outgoing = LocalizedString("transaction.details.type.outgoing",
                                              comment: "'Outgoing' transaction type")
    }

    @IBOutlet weak var senderView: TransactionParticipantView!
    @IBOutlet weak var recipientView: TransactionParticipantView!
    @IBOutlet weak var transactionValueView: TransactionValueView!
    @IBOutlet weak var transactionTypeView: TransactionParameterView!
    @IBOutlet weak var submittedParameterView: TransactionParameterView!
    @IBOutlet weak var transactionStatusView: StatusTransactionParameterView!
    @IBOutlet weak var transactionFeeView: TokenAmountTransactionParameterView!
    @IBOutlet weak var viewInExternalAppButton: UIButton!

    public private(set) var transactionID: String!
    private var transaction: TransactionData!

    private let dateFormatter = DateFormatter()

    public static func create(transactionID: String) -> TransactionDetailsViewController {
        let controller = StoryboardScene.Main.transactionDetailsViewController.instantiate()
        controller.transactionID = transactionID
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        transaction = ApplicationServiceRegistry.walletService.transactionData(transactionID)
        configureSender()
        configureRecipient()
        configureAmount()
        configureType()
        configureSubmitted()
        configureStatus()
        configureFee()
        configureViewInOtherApp()
    }

    private func configureSender() {
        senderView.name = ""
        senderView.address = transaction.sender
    }

    private func configureRecipient() {
        recipientView.name = ""
        recipientView.address = transaction.recipient
    }

    private func configureAmount() {
        transactionValueView.isSingleValue = true
        transactionValueView.style = .negative
        let formatter = TokenNumberFormatter.ERC20Token(code: transaction.token, decimals: transaction.tokenDecimals)
        transactionValueView.tokenAmount = formatter.string(from: transaction.amount)
    }

    private func configureType() {
        transactionTypeView.name = Strings.type
        switch transaction.type {
        case .outgoing: transactionTypeView.value = Strings.outgoing
        }
    }

    private func configureSubmitted() {
        submittedParameterView.name = Strings.submitted
        submittedParameterView.value = string(from: transaction.submitted!)
    }

    private func configureStatus() {
        transactionStatusView.name = Strings.status
        switch transaction.status {
        case .rejected:
            transactionStatusView.status = .rejected
        case .failed:
            transactionStatusView.status = .failed
        case .success:
            transactionStatusView.status = .success
        default:
            transactionStatusView.status = .pending
        }
        transactionStatusView.value = string(from: transaction.displayDate!)
    }

    private func configureFee() {
        transactionFeeView.name = Strings.fee
        transactionFeeView.style = .negative
        let formatter = TokenNumberFormatter.ERC20Token(code: transaction.feeToken,
                                                        decimals: transaction.feeTokenDecimals)
        transactionFeeView.value = formatter.string(from: transaction.fee)
    }

    private func configureViewInOtherApp() {
        viewInExternalAppButton.setTitle(Strings.externalApp, for: .normal)
    }

    func string(from date: Date) -> String {
        return "\(dateFormatter.string(from: date)) (\(date.timeAgoSinceNow))"
    }

}
