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

    // Either transactionFeeView or tokenBalanceView and feeBalanceView are visible at the same time
    @IBOutlet weak var transactionFeeView: TransactionFeeView!

    @IBOutlet weak var tokenBalanceView: TransactionFeeView!
    @IBOutlet weak var feeBalanceView: TransactionFeeView!
    @IBOutlet weak var feeBackgroundView: UIView!

    weak var delegate: FundsTransferTransactionViewControllerDelegate?

    private var keyboardBehavior: KeyboardAvoidingBehavior!
    internal var model: FundsTransferTransactionViewModel!
    internal var transactionID: String?

    private var tokenID: BaseID!
    private let feeTokenID: BaseID = ethID

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
        contentView.backgroundColor = .white
        backgroundView.isDimmed = true
        nextBarButton.title = FundsTransferTransactionViewController.Strings.continue
        nextBarButton.accessibilityIdentifier = "transaction.continue"
        keyboardBehavior = KeyboardAvoidingBehavior(scrollView: scrollView)

        model = FundsTransferTransactionViewModel(tokenID: tokenID, onUpdate: updateFromViewModel)

        addressInput.addressInputDelegate = self
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
        tokenInput.usesEthDefaultImage = true
        tokenInput.imageURL = model.tokenData.logoURL
        tokenInput.delegate = self

        transactionHeaderView.usesEthImageWhenImageURLIsNil = true
        feeBalanceView.backgroundColor = .clear
        feeBackgroundView.backgroundColor = .white
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
        if tokenID == feeTokenID {
            transactionFeeView.isHidden = false
            tokenBalanceView.isHidden = true
            feeBalanceView.isHidden = true
            feeBackgroundView.isHidden = true
            transactionFeeView.configure(currentBalance: model.feeBalanceTokenData,
                                         transactionFee: model.feeAmountTokenData,
                                         resultingBalance: model.feeResultingBalanceTokenData)
        } else {
            transactionFeeView.isHidden = true
            tokenBalanceView.isHidden = false
            feeBalanceView.isHidden = false
            feeBackgroundView.isHidden = false
            tokenBalanceView.configure(currentBalance: model.tokenData,
                                       transactionFee: nil,
                                       resultingBalance: model.resultingTokenData)
            feeBalanceView.configure(currentBalance: nil,
                                     transactionFee: model.feeAmountTokenData,
                                     resultingBalance: model.feeResultingBalanceTokenData)
        }
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
            DispatchQueue.main.async {
                ApplicationServiceRegistry.walletService.removeDraftTransaction(id)
            }
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
