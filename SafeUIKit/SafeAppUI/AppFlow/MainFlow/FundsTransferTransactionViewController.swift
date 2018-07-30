//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import BigInt

class FundsTransferTransactionViewController: UIViewController {

    @IBOutlet weak var participantView: TransactionParticipantView!
    @IBOutlet weak var valueView: TransactionValueView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var recipientTextField: UITextField!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var continueButton: BorderedButton!

    private let tokenFormatter = TokenNumberFormatter()
    private let defaultFeeValue = "n/a"
    private let userInputQueue = OperationQueue()

    static func create() -> FundsTransferTransactionViewController {
        return StoryboardScene.Main.fundsTransferTransactionViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        userInputQueue.maxConcurrentOperationCount = 1
        participantView.name = "Safe"
        participantView.address = ApplicationServiceRegistry.walletService.selectedWalletAddress!
        tokenFormatter.decimals = 18
        tokenFormatter.tokenCode = "ETH"
        let balance = ApplicationServiceRegistry.walletService.accountBalance(token: "ETH")!
        valueView.tokenAmount = tokenFormatter.string(from: BigInt(balance))
        valueView.fiatAmount = ""
        balanceLabel.text = valueView.tokenAmount
        feeLabel.text = defaultFeeValue
        amountTextField.delegate = self
        recipientTextField.delegate = self
        updateFeeEstimation(amount: amountTextField.text, recipient: recipientTextField.text)
    }

    fileprivate func estimate(_ amount: String?, _ recipient: String?) -> BigInt? {
        guard let amountText = amount, let amount = tokenFormatter.number(from: amountText) else { return nil }
        return ApplicationServiceRegistry.walletService.estimateTransferFee(amount: amount, address: recipient)
    }

    func updateFeeEstimation(amount: String?, recipient: String?) {
        userInputQueue.cancelAllOperations()
        userInputQueue.addOperation(CancellableBlockOperation { [weak self] op in
            guard let `self` = self else { return }
            if op.isCancelled { return }
            let estimation = self.estimate(amount, recipient)
            if op.isCancelled { return }
            DispatchQueue.main.sync {
                self.updateFee(estimation: estimation)
            }
        })
    }

    func updateFee(estimation: BigInt?) {
        if estimation == nil {
            feeLabel.text = defaultFeeValue
        } else {
            feeLabel.text = tokenFormatter.string(from: -estimation!)
        }
    }

    class CancellableBlockOperation: Operation {

        let block: (CancellableBlockOperation) -> Void

        init(block: @escaping (CancellableBlockOperation) -> Void) {
            self.block = block
        }

        override func main() {
            block(self)
        }

    }
}

extension FundsTransferTransactionViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let newValue = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        updateFeeEstimation(for: textField, newValue: newValue)
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        updateFeeEstimation(for: textField, newValue: nil)
        return true
    }

    private func updateFeeEstimation(for textField: UITextField, newValue: String?) {
        let amount = textField === amountTextField ? newValue : amountTextField.text
        let recipient = textField === recipientTextField ? newValue : recipientTextField.text
        updateFeeEstimation(amount: amount, recipient: recipient)
    }
}
