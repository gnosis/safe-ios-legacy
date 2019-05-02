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

    // Either transactionFeeView or tokenBalanceView and feeBalanceView are visible at the same time
    @IBOutlet weak var transactionFeeView: TransactionFeeView!
    @IBOutlet weak var tokenBalanceView: TransactionFeeView!
    @IBOutlet weak var feeBalanceView: TransactionFeeView!

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
        if tokenID == feeTokenID {
            feeCalculationView.calculation = SendEthFeeCalculation()
        } else {
            feeCalculationView.calculation = SendERC20FeeCalculation()
        }
        model.start()

        DispatchQueue.main.async {
            // For unknown reasons, the blockies (identicon) does not show up if updated in the viewDidLoad
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

        let formatter = TokenNumberFormatter.ERC20Token(code: model.feeAmountTokenData.code,
                                                        decimals: model.feeAmountTokenData.decimals,
                                                        displayedDecimals: 5)

        if tokenID == feeTokenID {
            let calculation = feeCalculationView.calculation as! SendEthFeeCalculation


            let fee = formatter.string(from: model.feeAmountTokenData.balance ?? 0)
            calculation.networkFeeLine.set(value: fee)
            let resultingBalance = formatter.string(from: model.feeResultingBalanceTokenData.balance ?? 0)
            calculation.resultingBalanceLine.set(value: resultingBalance)

            calculation.errorLine.text = ""
            calculation.resultingBalanceLine.set(error: nil)
            if model.hasEnoughFunds() == false {
                let error = FeeCalculationError.insufficientBalance
                calculation.errorLine.text = error.localizedDescription
                calculation.resultingBalanceLine.set(error: error)
            }
            calculation.update()
            feeCalculationView.update()
        } else {
            let calculation = feeCalculationView.calculation as! SendERC20FeeCalculation
            formatter.tokenCode = model.resultingTokenData.code
            formatter.decimals = model.resultingTokenData.decimals
            let resultingBalance = formatter.string(from: model.resultingTokenData.balance ?? 0)
            calculation.resultingBalanceLine.set(value: resultingBalance)

            formatter.tokenCode = model.feeAmountTokenData.code
            formatter.decimals = model.feeAmountTokenData.decimals

            let feeBalance = formatter.string(from: model.feeBalanceTokenData.balance ?? 0)
            calculation.networkFeeBalance.set(value: feeBalance)

            let fee = formatter.string(from: model.feeAmountTokenData.balance ?? 0)
            calculation.networkFeeLine.set(value: fee)

            let feeResultingBalance = formatter.string(from: model.feeResultingBalanceTokenData.balance ?? 0)
            calculation.networkFeeResultingBalanceLine.set(value: feeResultingBalance)

            calculation.errorLine.text = ""
            calculation.resultingBalanceLine.set(error: nil)
            calculation.networkFeeBalanceErrorLine.text = ""
            calculation.networkFeeResultingBalanceLine.set(error: nil)
            if model.hasEnoughFunds() == false {
                let error = FeeCalculationError.insufficientBalance

                if (model.resultingTokenData.balance ?? 0) < 0 {
                    calculation.errorLine.text = error.localizedDescription
                    calculation.resultingBalanceLine.set(error: error)
                }

                if (model.feeResultingBalanceTokenData.balance ?? 0) < 0 {
                    calculation.networkFeeBalanceErrorLine.text = error.localizedDescription
                    calculation.networkFeeResultingBalanceLine.set(error: error)
                }
            }
            calculation.update()
            feeCalculationView.update()
        }
        nextBarButton.isEnabled = model.canProceedToSigning
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

class SendEthFeeCalculation: FeeCalculation {

    enum Strings {

        static let currentBalance = LocalizedString("safe_balance", comment: "Current balance")
        static let networkFee = LocalizedString("transaction_fee", comment: "Network fee")
        static let resultingBalance = LocalizedString("balance_after_transfer", comment: "Balance after transfer")
        static let loading = "-"
        static let feeInfo = "[?]"

    }

    var networkFeeLine: FeeCalculationAssetLine
    var resultingBalanceLine: FeeCalculationAssetLine
    var errorLine: FeeCalculationErrorLine

    required init() {
        networkFeeLine = FeeCalculationAssetLine()
            .set(name: Strings.networkFee)
            .set(value: Strings.loading)
            .set(button: Strings.feeInfo, target: nil, action: Selector(("showTransactionFeeInfo")))
        resultingBalanceLine = FeeCalculationAssetLine()
            .set(style: .balance)
            .set(name: Strings.resultingBalance)
            .set(value: Strings.loading)
        errorLine = FeeCalculationErrorLine(text: Strings.loading)
        super.init()
        update()
    }

    func update() {
        let section = FeeCalculationSection([networkFeeLine, resultingBalanceLine, errorLine])
        section.border = nil
        section.insets = .zero
        elements = [section]
    }

}

class SendERC20FeeCalculation: SendEthFeeCalculation {

    var networkFeeBalance: FeeCalculationAssetLine
    var networkFeeResultingBalanceLine: FeeCalculationAssetLine
    var networkFeeBalanceErrorLine: FeeCalculationErrorLine

    required init() {
        networkFeeBalance = FeeCalculationAssetLine()
            .set(name: Strings.currentBalance)
            .set(value: Strings.loading)
        networkFeeResultingBalanceLine = FeeCalculationAssetLine()
            .set(style: .balance)
            .set(name: Strings.resultingBalance)
            .set(value: Strings.loading)
        networkFeeBalanceErrorLine = FeeCalculationErrorLine(text: Strings.loading)
        super.init()
    }

    override func update() {
        let section = FeeCalculationSection([resultingBalanceLine,
                                             errorLine,
                                             FeeCalculationSpacingLine(spacing: 20),
                                             networkFeeBalance,
                                             networkFeeLine,
                                             networkFeeResultingBalanceLine,
                                             networkFeeBalanceErrorLine])
        section.border = nil
        section.insets = .zero
        elements = [section]
    }
}
