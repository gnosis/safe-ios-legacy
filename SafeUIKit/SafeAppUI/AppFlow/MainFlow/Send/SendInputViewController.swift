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
    private let feeTokenID: BaseID = ethID

    public static func create(tokenID: BaseID) -> SendInputViewController {
        let controller = StoryboardScene.Main.sendInputViewController.instantiate()
        controller.tokenID = tokenID
        return controller
    }

    private enum Strings {
        static let titleFormatString = LocalizedString("send_title", comment: "Send")
        static let `continue` = LocalizedString("review", comment: "Review button for Send screen")

        // errors
        static let notEnoughFunds = LocalizedString("exceeds_funds",
                                                    comment: "Not enough balance for transaction.")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        contentView.backgroundColor = .white
        nextBarButton.title = SendInputViewController.Strings.continue
        nextBarButton.accessibilityIdentifier = "transaction.continue"
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)

        model = SendInputViewModel(tokenID: tokenID, onUpdate: updateFromViewModel)

        navigationItem.title = String(format: Strings.titleFormatString, model.tokenData.code)

        addressInput.addressInputDelegate = self
        addressInput.textInput.accessibilityIdentifier = "transaction.address"

        tokenInput.addRule(Strings.notEnoughFunds, identifier: "notEnoughFunds") { [unowned self] in
            guard self.tokenInput.formatter.number(from: $0) != nil else { return true }
            self.model.change(amount: $0)
            return self.model.hasEnoughFunds() ?? false
        }
        tokenInput.setUp(value: 0, decimals: model.tokenData.decimals)
        tokenInput.usesEthDefaultImage = true
        tokenInput.imageURL = model.tokenData.logoURL
        tokenInput.tokenCode = model.tokenData.code
        tokenInput.delegate = self
        tokenInput.textInput.accessibilityIdentifier = "transaction.amount"
        feeCalculationView.calculation = tokenID == feeTokenID ? SendEthFeeCalculation() : SendERC20FeeCalculation()
        model.start()
        DispatchQueue.main.async {
            // For unknown reasons, the identicon does not show up if updated in the viewDidLoad
            self.accountBalanceHeaderView.address = ApplicationServiceRegistry.walletService.selectedWalletAddress
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardBehavior.start()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(SendTrackingEvent(.input, token: model.tokenData.address, tokenName: model.tokenData.code))
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardBehavior.stop()
    }

    func updateFromViewModel() {
        accountBalanceHeaderView.amount = model.tokenData
        if tokenID == feeTokenID {
            let calculation = feeCalculationView.calculation as! SendEthFeeCalculation
            calculation.networkFeeLine.set(value: model.feeAmountTokenData)
            calculation.resultingBalanceLine.set(value: model.feeResultingBalanceTokenData)
            calculation.setBalanceError(feeBalanceError())
        } else {
            let calculation = feeCalculationView.calculation as! SendERC20FeeCalculation
            calculation.resultingBalanceLine.set(value: model.resultingTokenData)
            calculation.setBalanceError(tokenBalanceError())
            calculation.networkFeeBalance.set(value: model.feeBalanceTokenData)
            calculation.networkFeeLine.set(value: model.feeAmountTokenData)
            calculation.networkFeeResultingBalanceLine.set(value: model.feeResultingBalanceTokenData)
            calculation.setFeeBalanceError(feeBalanceError())
        }
        feeCalculationView.update()
        nextBarButton.isEnabled = model.canProceedToSigning
    }

    private func tokenBalanceError() -> Error? {
        let isNegativeBalance = (model.resultingTokenData.balance ?? 0) < 0
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
                                  amount: model.intAmount ?? 0,
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
        present(TransactionFeeAlertController.create(), animated: true, completion: nil)
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
