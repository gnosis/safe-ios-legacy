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
    @IBOutlet weak var recipientStackView: UIStackView!
    @IBOutlet weak var amountStackView: UIStackView!

    private let tokenFormatter = TokenNumberFormatter()
    private lazy var amountValidator = TokenAmountValidator(formatter: tokenFormatter,
                                                            range: BigInt(0)..<BigInt(2).power(256) - 1)
    private let addressValidator = EthereumAddressValidator(byteCount: 20)
    private let defaultFeeValue = "--"
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

    private func estimate(_ amount: String?, _ recipient: String?) -> BigInt? {
        guard let amountText = amount, let amount = tokenFormatter.number(from: amountText) else { return nil }
        return ApplicationServiceRegistry.walletService.estimateTransferFee(amount: amount, address: recipient)
    }

    private func updateFeeEstimation(amount: String?, recipient: String?) {
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

    private func updateFee(estimation: BigInt?) {
        if estimation == nil {
            feeLabel.text = defaultFeeValue
        } else {
            feeLabel.text = tokenFormatter.string(from: -estimation!)
        }
    }

    private func validate(_ textField: UITextField, _ value: String?) {
        if textField === amountTextField {
            validate(value: value, with: amountValidator, in: amountStackView)
        } else if textField === recipientTextField {
            validate(value: value, with: addressValidator, in: recipientStackView)
        }
    }

    private func validate<V: Validator>(value: String?, with validator: V, in stack: UIStackView) {
        clearErrors(in: stack)
        guard let value = value,
            let error = validator.validate(value) else { return }
        showError(error, in: stack)
    }

    private func clearErrors(in stack: UIStackView) {
        while stack.arrangedSubviews.count > 1 {
            stack.arrangedSubviews.last!.removeFromSuperview()
        }
    }

    private func showError(_ error: Error, in stack: UIStackView) {
        let wrapperView = UIView()
        let errorLabel = UILabel()
        errorLabel.font = UIFont.preferredFont(forTextStyle: .body)
        errorLabel.textColor = ColorName.tomato.color
        errorLabel.numberOfLines = 0
        errorLabel.text = error.localizedDescription

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(errorLabel)
        stack.addArrangedSubview(wrapperView)
        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: 16),
            errorLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 8),
            errorLabel.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: 8)])
    }
}

extension EthereumAddressValidator.ValidationError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .empty:
            return LocalizedString("transaction.error.emptyAddress", comment: "Address is empty but it is required")
        case let .invalidCharacter(character, offset):
            let format = LocalizedString("transaction.error.invalidAddressCharacterAt",
                                         comment: "Invalid character '%@' at position '%d'")
            let position = offset + 1
            return String(format: format, character, position)
        case let .valueTooShort(count, requiredCount):
            let format = LocalizedString("transaction.error.addressIsTooShort",
                                         comment: "Address length '%d' is too short for required length '%d'")
            return String(format: format, count, requiredCount)
        case let .valueTooLong(count, requiredCount):
            let format = LocalizedString("transaction.error.addressIsTooLong",
                                         comment: "Address length '%d' is too long for required length '%d'")
            return String(format: format, count, requiredCount)
        case .zeroAddress:
            return LocalizedString("transaction.error.zeroAddressInvalidForTransfer",
                                   comment: "Zero address is invalid for transfer of tokens")
        }
    }

}

extension TokenAmountValidator.ValidationError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .empty: return LocalizedString("transaction.error.emptyAmount",
                                            comment: "Amount is empty but it is required")
        case .valueIsTooBig:
            return LocalizedString("transaction.error.amountTooBig",
                                   comment: "Amount is too big value for transfer.")
        case .valueIsTooSmall:
            return LocalizedString("transaction.error.amountTooSmall",
                                   comment: "Amount is too small value for transfer.")
        case .valueIsNegative:
            return LocalizedString("transaction.error.amountNegative",
                                   comment: "Transfer amount must be a positive value")
        case .notANumber:
            return LocalizedString("transaction.error.amountNotANumber",
                                   comment: "Transfer amount must be a valid number")
        }
    }

}

fileprivate class CancellableBlockOperation: Operation {

    let block: (CancellableBlockOperation) -> Void

    init(block: @escaping (CancellableBlockOperation) -> Void) {
        self.block = block
    }

    override func main() {
        block(self)
    }

}

extension FundsTransferTransactionViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let newValue = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        updateFeeEstimation(for: textField, newValue: newValue)
        validate(textField, newValue)
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
