//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Common

protocol FundsTransferTransactionViewControllerDelegate: class {
    func didCreateDraftTransaction(id: String)
}

public class FundsTransferTransactionViewController: UIViewController {

    @IBOutlet weak var tokenCodeLabel: UILabel!
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
    @IBOutlet weak var scrollView: UIScrollView!

    weak var delegate: FundsTransferTransactionViewControllerDelegate?

    private var keyboardBehavior: KeyboardAvoidingBehavior!
    internal var model: FundsTransferTransactionViewModel!
    internal var transactionID: String?
    private var textFields: [UITextField] {
        return [amountTextField, recipientTextField]
    }

    private var tokenID: BaseID!

    public static func create(tokenID: BaseID) -> FundsTransferTransactionViewController {
        let controller = StoryboardScene.Main.fundsTransferTransactionViewController.instantiate()
        controller.tokenID = tokenID
        return controller
    }

    private enum Strings {
        static let title = LocalizedString("transaction.title",
                                           comment: "Send")
        static let `continue` = LocalizedString("transaction.continue",
                                                comment: "Continue button title for New Transaction Screen")
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        navigationItem.title = Strings.title
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        model = FundsTransferTransactionViewModel(senderName: "Safe", tokenID: tokenID, onUpdate: updateFromViewModel)
        amountTextField.delegate = self
        amountTextField.accessibilityIdentifier = "transaction.amount"
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        amountTextField.placeholder = numberFormatter.string(from: NSNumber(value: 0))
        recipientTextField.delegate = self
        recipientTextField.accessibilityIdentifier = "transaction.address"
        continueButton.addTarget(self, action: #selector(proceedToSigning(_:)), for: .touchUpInside)
        continueButton.setTitle(Strings.continue, for: .normal)
        continueButton.accessibilityIdentifier = "transaction.continue"
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)
        feeLabel.accessibilityIdentifier = "transaction.fee"
        model.start()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardBehavior.start()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardBehavior.stop()
    }

    func updateFromViewModel() {
        tokenCodeLabel.text = model.tokenCode

        participantView.name = model.senderName
        participantView.address = model.senderAddress

        valueView.tokenAmount = model.balance ?? ""
        valueView.fiatAmount = ""
        valueView.style = .neutral

        balanceLabel.text = model.feeBalance
        feeLabel.text = model.fee

        clearErrors(in: amountStackView)
        model.amountErrors.forEach { showError($0, in: amountStackView) }

        clearErrors(in: recipientStackView)
        model.recipientErrors.forEach { showError($0, in: recipientStackView) }

        continueButton.isEnabled = model.canProceedToSigning
    }

    @objc func proceedToSigning(_ sender: Any) {
        let service = ApplicationServiceRegistry.walletService
        transactionID = service.createNewDraftTransaction()
        service.updateTransaction(transactionID!,
                                  amount: model.intAmount!,
                                  token: tokenID.id,
                                  recipient: model.recipient!)
        delegate?.didCreateDraftTransaction(id: transactionID!)
    }

    func willBeRemoved() {
        if let id = transactionID {
            ApplicationServiceRegistry.walletService.removeDraftTransaction(id)
        }
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

extension FundsTransferTransactionViewController: UITextFieldDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardBehavior.activeTextField = textField
    }

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {
        let newValue = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        update(textField, newValue: newValue)
        return true
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        update(textField, newValue: nil)
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let index = textFields.index(where: { $0 === textField }) {
            if index < textFields.count - 1 {
                textFields[index + 1].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
                if model.canProceedToSigning {
                    proceedToSigning(textField)
                }
            }
        }
        return true
    }

    private func update(_ textField: UITextField, newValue: String?) {
        if textField == amountTextField {
            model.change(amount: newValue)
        } else if textField == recipientTextField {
            model.change(recipient: newValue)
        }
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

extension FundsValidator.ValidationError: LocalizedError {

    var errorDescription: String? {
        return LocalizedString("transaction.error.notEnoughFunds", comment: "Not enough balance for transaction.")
    }

}
