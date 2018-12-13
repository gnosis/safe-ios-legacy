//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common
import BigInt
import MultisigWalletApplication

protocol ReplaceRecoveryPhraseViewControllerDelegate: class {

    func replaceRecoveryPhraseViewControllerDidStart()

}

class ReplaceRecoveryPhraseViewController: UIViewController {

    struct Strings {
        static let header = LocalizedString("replace_phrase.header", comment: "Replace recovery phrase")
        static let body = LocalizedString("replace_phrase.body", comment: "Text between stars (*) will be emphasized")
    }

    @IBOutlet weak var startButtonItem: UIBarButtonItem!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var transactionFeeView: TransactionFeeView!

    weak var delegate: ReplaceRecoveryPhraseViewControllerDelegate?

    var headerStyle = HeaderStyle.contentHeader
    var bodyStyle = BodyStyle.default
    var bodyEmphasisStyle = BodyStyle.emphasis

    var transaction: TransactionData?
    var isReadyToStart: Bool = false

    static func create(delegate: ReplaceRecoveryPhraseViewControllerDelegate?) -> ReplaceRecoveryPhraseViewController {
        let controller = StoryboardScene.Main.replaceRecoveryPhraseViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.attributedText = .header(from: Strings.header)
        bodyLabel.attributedText = parsedAttributedBodyText(from: Strings.body, marker: "*")
        update()
        createTransaction()
        observeBalance()
    }

    func update() {
        assert(Thread.isMainThread)
        guard isViewLoaded else { return }
        guard let tx = transaction else {
            startButtonItem.isEnabled = false
            transactionFeeView.configure(currentBalance: nil, transactionFee: nil, resultingBalance: nil)
            return
        }
        let balance = (ApplicationServiceRegistry
            .walletService.accountBalance(tokenID: BaseID(tx.feeTokenData.address)) ?? 0)
        let feeBalance = tx.feeTokenData.withBalance(balance)
        let feeAmount = tx.feeTokenData
        let resultingBalance = tx.feeTokenData.withBalance(balance - abs(tx.feeTokenData.balance ?? 0))
        transactionFeeView.configure(currentBalance: feeBalance,
                                     transactionFee: feeAmount,
                                     resultingBalance: resultingBalance)
        startButtonItem.isEnabled = isReadyToStart
    }

    private func parsedAttributedBodyText(from string: String, marker: String) -> NSAttributedString {
        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = nil
        var intermediateResult: NSString!
        let result = NSMutableAttributedString()
        var didScan = scanner.scanUpTo(marker, into: &intermediateResult)
        while didScan {
            result.append(.body(from: intermediateResult as String, style: bodyStyle)!)
            scanner.scanString(marker, into: nil)
            let hasEmphasis = scanner.scanUpTo(marker, into: &intermediateResult)
            if hasEmphasis {
                result.append(.body(from: intermediateResult as String, style: bodyEmphasisStyle)!)
                scanner.scanString(marker, into: nil)
            }
            didScan = scanner.scanUpTo(marker, into: &intermediateResult)
        }
        return result
    }

    func createTransaction() {
        DispatchQueue.global().async { [unowned self] in
            self.transaction = ApplicationServiceRegistry.settingsService.createRecoveryPhraseTransaction()
            self.isReadyToStart = ApplicationServiceRegistry
                .settingsService.isRecoveryPhraseTransactionReadyToStart(self.transaction!.id)
            DispatchQueue.main.async {
                self.update()
            }
        }
    }

    func observeBalance() {
        DispatchQueue.global().async {
            ApplicationServiceRegistry.recoveryService.observeBalance(subscriber: self)
        }
    }

    @IBAction func start(_ sender: Any) {
        showConfirmationAlert()
    }

    func doStart() {
        delegate?.replaceRecoveryPhraseViewControllerDidStart()
    }

    func showConfirmationAlert() {

        let alert = UIAlertController(title: LocalizedString("replace_phrase.confirm.title",
                                                             comment: "Confirmation alert title"),
                                      message: LocalizedString("replace_phrase.confirm.message",
                                                               comment: "Confirmation alert message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString("replace_phrase.confirm.yes",
                                                             comment: "Affirmative response button title"),
                                      style: .default,
                                      handler: SafeAlertController.wrap { [unowned self] in
                                        self.doStart()
        }))
        alert.addAction(UIAlertAction(title: LocalizedString("replace_phrase.confirm.cancel",
                                                             comment: "Cancel response button title"),
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
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
        present(alert, animated: true)
    }

}

extension ReplaceRecoveryPhraseViewController: EventSubscriber {

    public func notify() {
        guard let id = transaction?.id else { return }
        isReadyToStart = ApplicationServiceRegistry.settingsService.isRecoveryPhraseTransactionReadyToStart(id)
        DispatchQueue.main.async {
            self.update()
        }
    }

}
