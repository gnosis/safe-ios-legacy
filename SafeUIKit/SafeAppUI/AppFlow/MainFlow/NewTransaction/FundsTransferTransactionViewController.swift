//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Common
import SafeUIKit

protocol FundsTransferTransactionViewControllerDelegate: class {
    func didCreateDraftTransaction(id: String)
}

public class InputCell: ContainerCell {

    public override var horizontalMargin: CGFloat { return 15 }
    public override var verticalMargin: CGFloat { return 20 }

    public override func commonInit() {
        super.commonInit()
        backgroundColor = ColorName.paleGreyThree.color
    }

}

public class AddressCell: InputCell {

    let addressInput = AddressInput(frame: .zero)
    public override var cellContentView: UIView { return addressInput }

}

public class AmountCell: InputCell {

    let tokenInput = TokenInput(frame: .zero)
    public override var cellContentView: UIView { return tokenInput }

}

public class FundsTransferViewController: UITableViewController {

    var cells = [IndexPath: UITableViewCell]()
    let backgroundView = BackgroundImageView(frame: .zero)
    let stickyHeaderView = UIView(frame: .zero)
    let headerViewCell = TransactionHeaderCell(frame: .zero)
    let recipientCell = AddressCell(frame: .zero)
    let amountCell = AmountCell(frame: .zero)
    let feeCell = TransactionFeeCell(frame: .zero)

    public override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.isDimmed = true
        tableView.backgroundView = backgroundView
        tableView.estimatedRowHeight = 75
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        configureTableStickyHeader()
        recipientCell.addressInput.addressInputDelegate = self
        amountCell.tokenInput.usesEthDefaultImage = true
        cells[IndexPath(row: 0, section: 0)] = headerViewCell
        cells[IndexPath(row: 1, section: 0)] = recipientCell
        cells[IndexPath(row: 2, section: 0)] = amountCell
        cells[IndexPath(row: 3, section: 0)] = feeCell
    }

    private func configureTableStickyHeader() {
        assert(tableView.backgroundView != nil, "You must set the tableView's backgroundView first")
        stickyHeaderView.backgroundColor = ColorName.paleGreyThree.color
        stickyHeaderView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stickyHeaderView)
        NSLayoutConstraint.activate([
            stickyHeaderView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            stickyHeaderView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            stickyHeaderView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            stickyHeaderView.bottomAnchor.constraint(equalTo: tableView.topAnchor)])
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.keys.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath]!
    }

}

extension FundsTransferViewController: AddressInputDelegate {

    public func presentController(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }

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

    let vc = FundsTransferViewController()

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

        addChild(vc)
        vc.view.frame = view.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(vc.view)
        vc.didMove(toParent: self)

        vc.recipientCell.addressInput.addRule("none", identifier: nil) { [unowned self] in
            self.model.change(recipient: $0)
            return true
        }
        vc.amountCell.tokenInput.addRule("NO FUNDS", identifier: "notEnoughFunds") { [unowned self] in
            self.model.change(amount: $0)
            return self.model.hasEnoughFunds() ?? false
        }

        vc.amountCell.tokenInput.setUp(value: 0, decimals: model.tokenData.decimals)
        vc.amountCell.tokenInput.imageURL = model.tokenData.logoURL

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

        updateVC()
    }

    func updateVC() {
        vc.headerViewCell.configure(imageURL: model.tokenData.logoURL,
                                    code: model.tokenData.code,
                                    info: model.balance ?? "")
        vc.feeCell.transactionFeeView.configure(currentBalance: model.feeBalanceTokenData,
                                                transactionFee: model.feeAmountTokenData,
                                                resultingBalance: model.feeResultingBalanceTokenData)
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
