//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Common
import SafeUIKit

protocol SendInputViewControllerDelegate: class {
    func didCreateDraftTransaction(id: String)
}

public class SendInputViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var addressInput: AddressInput!
    @IBOutlet weak var tokenInput: TokenInput!
    @IBOutlet weak var accountBalanceHeaderView: AccountBalanceView!
    @IBOutlet weak var feeCalculationView: FeeCalculationView!

    weak var delegate: SendInputViewControllerDelegate?

    private var keyboardBehavior: KeyboardAvoidingBehavior!
    internal var model: SendInputViewModel!
    internal var transactionID: String?

    private var tokenID: BaseID!
    private var feeTokenID: BaseID {
        return BaseID(ApplicationServiceRegistry.walletService.feePaymentTokenData.address)
    }
    private var needsEstimation: Bool = false

    public static func create(tokenID: BaseID) -> SendInputViewController {
        let controller = StoryboardScene.Main.sendInputViewController.instantiate()
        controller.tokenID = tokenID
        return controller
    }

    private enum Strings {
        static let titleFormatString = LocalizedString("send_title", comment: "Send")
        static let `continue` = LocalizedString("review", comment: "Review button for Send screen")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        contentView.backgroundColor = .white
        nextBarButton.title = SendInputViewController.Strings.continue
        nextBarButton.accessibilityIdentifier = "transaction.continue"
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)

        model = SendInputViewModel(tokenID: tokenID, onUpdate: updateFromViewModel)

        navigationItem.title = String(format: Strings.titleFormatString, model.accountBalanceTokenData.code)

        addressInput.addressInputDelegate = self
        addressInput.textInput.accessibilityIdentifier = "transaction.address"
        addressInput.spacingAfterInput = 0

        tokenInput.addRule("", identifier: "notEnoughFunds") { [unowned self] in
            let number = self.tokenInput.formatter.number(from: $0,
                                                          precision: self.model.accountBalanceTokenData.decimals)
            guard let amount = number else { return true }
            self.model.change(amount: amount.value)
            return self.model.hasEnoughFunds()
        }
        tokenInput.setUp(value: 0, decimals: model.accountBalanceTokenData.decimals)
        tokenInput.usesEthDefaultImage = true
        tokenInput.imageURL = model.accountBalanceTokenData.logoURL
        tokenInput.tokenCode = model.accountBalanceTokenData.code
        tokenInput.delegate = self
        tokenInput.textInput.accessibilityIdentifier = "transaction.amount"
        tokenInput.textInput.keyboardTargetView = tokenInput.superview

        setNeedsEstimation()

        DispatchQueue.main.async {
            // For unknown reasons, the identicon does not show up if updated in the viewDidLoad
            self.accountBalanceHeaderView.address = ApplicationServiceRegistry.walletService.selectedWalletAddress
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardBehavior.start()
        updateFeeCalculationViewAndModel()
    }

    private func setNeedsEstimation() {
        needsEstimation = true
    }

    /// If user changed payment method, the fee calculation view should be updated with new fee token data.
    private func updateFeeCalculationViewAndModel() {
        guard needsEstimation else {
            return
        }
        needsEstimation = false
        feeCalculationView.calculation = tokenID == feeTokenID ? SameTransferAndPaymentTokensFeeCalculation() :
            DifferentTransferAndPaymentTokensFeeCalculation()
        model.resetEstimation()
        model.update()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(SendTrackingEvent(.input,
                                     token: model.accountBalanceTokenData.address,
                                     tokenName: model.accountBalanceTokenData.code))
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardBehavior.stop()
    }

    func updateFromViewModel() {
        accountBalanceHeaderView.amount = model.accountBalanceTokenData
        if tokenID == feeTokenID {
            let calculation = feeCalculationView.calculation as! SameTransferAndPaymentTokensFeeCalculation
            calculation.networkFeeLine.set(valueButton: model.feeEstimatedAmountTokenData.withNonNegativeBalance(),
                                           target: self,
                                           action: #selector(changePaymentMethod),
                                           roundUp: true)
            calculation.resultingBalanceLine.set(value: model.feeResultingBalanceTokenData)
            calculation.setBalanceError(feeBalanceError())
        } else {
            let calculation = feeCalculationView.calculation as! DifferentTransferAndPaymentTokensFeeCalculation
            calculation.resultingBalanceLine.set(value: model.resultingBalanceTokenData)
            calculation.setBalanceError(tokenBalanceError())
            calculation.networkFeeLine.set(valueButton: model.feeEstimatedAmountTokenData.withNonNegativeBalance(),
                                           target: self,
                                           action: #selector(changePaymentMethod),
                                           roundUp: true)
            calculation.networkFeeResultingBalanceLine.set(value: model.feeResultingBalanceTokenData)
            calculation.setFeeBalanceError(feeBalanceError())
        }
        feeCalculationView.update()
        nextBarButton.isEnabled = model.canProceedToSigning
        tokenInput.revalidateText()
    }

    private func tokenBalanceError() -> Error? {
        let isNegativeBalance = (model.resultingBalanceTokenData.balance ?? 0) < 0
        return  model.hasEnoughFunds() == false && isNegativeBalance ? FeeCalculationError.insufficientBalance : nil
    }

    private func feeBalanceError() -> Error? {
        let isNegativeFeeBalance = (model.feeResultingBalanceTokenData.balance ?? 0) < 0
        return model.hasEnoughFunds() == false && isNegativeFeeBalance ? FeeCalculationError.insufficientBalance : nil
    }

    @IBAction func proceedToSigning(_ sender: Any) {
        let service = ApplicationServiceRegistry.walletService
        transactionID = service.createNewDraftTransaction()
        service.updateTransaction(transactionID!,
                                  amount: model.amount ?? 0,
                                  token: tokenID.id,
                                  recipient: model.recipient!)
        delegate?.didCreateDraftTransaction(id: transactionID!)
    }

    func willBeRemoved() {
        if let id = transactionID {
            DispatchQueue.main.async {
                ApplicationServiceRegistry.walletService.removeDraftTransaction(id)
            }
        }
    }

    @objc func showTransactionFeeInfo() {
        present(UIAlertController.networkFee(), animated: true, completion: nil)
    }

    @objc private func changePaymentMethod() {
        let vc = PaymentMethodViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension SendInputViewController: AddressInputDelegate {

    public func didRecieveInvalidAddress(_ string: String) {}

    public func didClear() {}

    public func presentController(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }

    public func didRecieveValidAddress(_ address: String) {
        model.change(recipient: address)
    }

}

extension SendInputViewController: VerifiableInputDelegate {

    public func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        if model.canProceedToSigning {
            proceedToSigning(verifiableInput)
        }
    }

    public func verifiableInputDidBeginEditing(_ verifiableInput: VerifiableInput) {
        keyboardBehavior.activeTextField = verifiableInput.textInput
    }

}

extension SendInputViewController: PaymentMethodViewControllerDelegate {

    func paymentMethodViewControllerDidChangePaymentMethod(_ controller: PaymentMethodViewController) {
        setNeedsEstimation()
    }

}
