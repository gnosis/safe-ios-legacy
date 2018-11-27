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

public class FundsTransferTransactionViewController: UIViewController {

    @IBOutlet var backgroundView: BackgroundImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var transactionHeaderView: TransactionHeaderView!
    @IBOutlet weak var addressInput: AddressInput!
    @IBOutlet weak var tokenInput: TokenInput!
    @IBOutlet weak var transactionFeeView: TransactionFeeView!

    weak var delegate: FundsTransferTransactionViewControllerDelegate?

    private var keyboardBehavior: KeyboardAvoidingBehavior!
    internal var model: FundsTransferTransactionViewModel!
    internal var transactionID: String?

    private var tokenID: BaseID!

    public static func create(tokenID: BaseID) -> FundsTransferTransactionViewController {
        let controller = StoryboardScene.Main.fundsTransferTransactionViewController.instantiate()
        controller.tokenID = tokenID
        return controller
    }

    fileprivate enum Strings {
        static let title = LocalizedString("transaction.title",
                                           comment: "Send")
        static let `continue` = LocalizedString("transaction.continue",
                                                comment: "Continue button title for New Transaction Screen")
        static let notEnoughFunds = LocalizedString("transaction.error.notEnoughFunds",
                                                    comment: "Not enough balance for transaction.")
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        navigationItem.title = Strings.title
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        contentView.backgroundColor = ColorName.paleGreyThree.color
        backgroundView.isDimmed = true
        addressInput.addressInputDelegate = self
        nextBarButton.title = FundsTransferTransactionViewController.Strings.continue
        nextBarButton.accessibilityIdentifier = "transaction.continue"
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)
        model = FundsTransferTransactionViewModel(tokenID: tokenID, onUpdate: updateFromViewModel)
        addressInput.addRule("none", identifier: nil) { [unowned self] in
            self.model.change(recipient: $0)
            return true
        }
        tokenInput.addRule(Strings.notEnoughFunds, identifier: "notEnoughFunds") { [unowned self] in
            guard self.tokenInput.formatter.number(from: $0) != nil else { return true }
            self.model.change(amount: $0)
            return self.model.hasEnoughFunds() ?? false
        }
        tokenInput.setUp(value: 0, decimals: model.tokenData.decimals)
        transactionHeaderView.usesEthImageWhenImageURLIsNil = true
        tokenInput.usesEthDefaultImage = true
        tokenInput.imageURL = model.tokenData.logoURL
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
        transactionHeaderView.assetCode = model.tokenData.code
        transactionHeaderView.assetImageURL = model.tokenData.logoURL
        transactionHeaderView.assetInfo = model.balance
        transactionFeeView.configure(currentBalance: model.feeBalanceTokenData,
                                     transactionFee: model.feeAmountTokenData,
                                     resultingBalance: model.feeResultingBalanceTokenData)
        nextBarButton.isEnabled = model.canProceedToSigning
    }

    @IBAction func proceedToSigning(_ sender: Any) {
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

}

extension FundsTransferTransactionViewController: AddressInputDelegate {

    public func presentController(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }

}

extension FundsTransferTransactionViewController: VerifiableInputDelegate {

    public func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        if model.canProceedToSigning {
            proceedToSigning(verifiableInput)
        }
    }

    public func verifiableInputDidBeginEditing(_ verifiableInput: VerifiableInput) {
        keyboardBehavior.activeTextField = verifiableInput.textInput
    }

}

extension FundsTransferTransactionViewController: UITextFieldDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardBehavior.activeTextField = textField
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
