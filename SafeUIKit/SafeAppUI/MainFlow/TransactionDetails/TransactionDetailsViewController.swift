//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import DateTools
import MultisigWalletApplication
import SafeUIKit
import Common

public protocol TransactionDetailsViewControllerDelegate: class {
    func showTransactionInExternalApp(from controller: TransactionDetailsViewController)
    func transactionDetailsViewController(_ controller: TransactionDetailsViewController,
                                          didSelectToEditNameForAddress address: String)
    func transactionDetailsViewController(_ controller: TransactionDetailsViewController,
                                          didSelectToSendToken token: TokenData,
                                          forAddress address: String)
    func transactionDetailsViewControllerDidSelectApprove(_ controller: TransactionDetailsViewController)
    func transactionDetailsViewControllerDidSelectExecute(_ controller: TransactionDetailsViewController)

}

internal class ClockService {
    var currentTime: Date {
        return Date()
    }
}

public class TransactionDetailsViewController: UIViewController {

    internal enum Strings {
        static let title = LocalizedString("transaction_details",
                                           comment: "Title for the transaction details screen")
        static let type = LocalizedString("type", comment: "'Type' parameter name")
        static let submitted = LocalizedString("header_submitted",
                                               comment: "'Submitted' parameter name")
        static let status = LocalizedString("status", comment: "'Status' parameter name")
        static let fee = LocalizedString("transaction_fee", comment: "Network fee")
        static let externalApp = LocalizedString("ios_view_transaction_on_etherscan",
                                                 comment: "'View on Etherscan' button name")
        static let outgoingType = LocalizedString("transaction_type_asset_transfer",
                                                  comment: "Outgoing transafer")
        static let settingsChangeType = LocalizedString("settings_change", comment: "Settings change")
        static let statusKeyacard = LocalizedString("status_keycard", comment: "Status Keycard")
        static let gnosisSafeAuthenticator = LocalizedString("gnosis_safe_authenticator",
                                                             comment: "Gnosis Safe Authenticator")

        enum ReplaceRecoveryPhrase {
            static let title = LocalizedString("ios_replace_recovery_phrase", comment: "Replace recovery phrase")
                .replacingOccurrences(of: "\n", with: " ")
            static let detail = LocalizedString("layout_replace_recovery_phrase_transaction_info_description",
                                                comment: "Detail for the header in review screen")
        }
        enum ReplaceTwoFA {
            static let title = LocalizedString("replace_2fa", comment: "Replace 2FA")
            static let detail = LocalizedString("replace_2fa_review_description",
                                                comment: "Replace 2FA review description")
        }
        enum PairTwoFA {
            static let title = LocalizedString("pair_2FA_device", comment: "Pair 2FA device")
            static let detail = LocalizedString("pair_2fa_review_description",
                                                comment: "Pair 2FA device review description")
        }
        enum DisableTwoFA {
            static let title = LocalizedString("disable_2fa",
                                               comment: "Disable 2FA")
            static let detail = LocalizedString("disable_2fa_review_description",
                                                comment: "Disable 2FA review description")
        }
        enum WalletRecovery {
            static let title = LocalizedString("ios_recovered_safe", comment: "Recovered Safe")
                .replacingOccurrences(of: "\n", with: " ")
            static let detail = LocalizedString("layout_recovered_safe_info_description",
                                                comment: "Detail for the header in review screen")
            static let detailWithAuthenticator = LocalizedString("layout_recovered_authenticator_safe_info_description",
                                                                 comment: "Recovery with authenticator")
        }
        enum ContractUpgrade {
            static let title = LocalizedString("ios_contract_upgrade", comment: "Contract upgrade")
                .replacingOccurrences(of: "\n", with: " ")

            static let detailFormat = LocalizedString("this_will_upgrade", comment: "Upgrading contract")

            static func detail(safeName: String = "Safe") -> String {
                return String(format: detailFormat, safeName)
            }
        }
        enum Batched {
            static let title = LocalizedString("batched_transaction", comment: "Batched")
            static func batchedDescription(_ txCount: Int) -> String {
                if txCount < 1 { return LocalizedString("empty_batch", comment: "No transactions") }
                return String(format: LocalizedString("perform_n_transactions", comment: "N transactions"), txCount)
            }
            static let viewDetails = LocalizedString("view_details", comment: "View Details")
        }
        enum AddressEntryActions {
            static let editDetails = LocalizedString("edit_entry_details", comment: "Edit entry details")
            static let addToAddressBook = LocalizedString("add_to_address_book", comment: "Add to address book")
            static let sendTokenAgain = LocalizedString("send_again", comment: "Send token again")
            static let cancel = LocalizedString("cancel", comment: "Cancel")
        }
    }
    @IBOutlet weak var transactionActionsView: TransactionActionsView!
    @IBOutlet weak var signatureTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var viewButton: StandardButton!
    @IBOutlet weak var separatorLineView: HorizontalSeparatorView!
    @IBOutlet weak var settingsHeaderView: SettingsTransactionHeaderView!
    @IBOutlet weak var transferView: TransferView!
    @IBOutlet weak var transactionTypeView: TransactionParameterView!
    @IBOutlet weak var submittedParameterView: TransactionParameterView!
    @IBOutlet weak var transactionStatusView: StatusTransactionParameterView!
    @IBOutlet weak var transactionFeeView: TokenAmountTransactionParameterView!
    @IBOutlet weak var viewInExternalAppButton: UIButton!
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var dataView: TransactionParameterView!
    @IBOutlet weak var signaturesContainerView: UIView!
    @IBOutlet weak var signaturesTableView: UITableView!
    @IBOutlet weak var transactionHashView: TransactionParameterView!
    @IBOutlet weak var safeHashView: TransactionParameterView!
    @IBOutlet weak var nonceView: TransactionParameterView!
    public weak var delegate: TransactionDetailsViewControllerDelegate?
    public private(set) var transactionID: String!
    private var transaction: TransactionData!
    internal var clock = ClockService()

    private let dateFormatter = DateFormatter()
    public static func create(transactionID: String) -> TransactionDetailsViewController {
        let controller = StoryboardScene.Main.transactionDetailsViewController.instantiate()
        controller.transactionID = transactionID
        return controller
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        navigationItem.title = Strings.title
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorName.snowwhite.color
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        ApplicationServiceRegistry.walletService.subscribeForTransactionUpdates(subscriber: self)
        wrapperView.backgroundColor = ColorName.snowwhite.color
        transferView.setSmallerAmountLabelFontSize()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(TransactionDetailTrackingEvent(type: trackingTrasnsactionType(from: transaction.type)))
    }

    func trackingTrasnsactionType(from type: TransactionData.TransactionType) -> TransactionDetailType {
        switch type {
        case .incoming, .outgoing: return .send
        case .replaceRecoveryPhrase: return .replaceRecoveryPhrase
        case .replaceTwoFAWithAuthenticator: return .replaceTwoFAWithAuthenticator
        case .connectAuthenticator: return .connectAuthenticator
        case .disconnectAuthenticator: return .disconnectAuthenticator
        case .walletRecovery: return .recoverSafe
        case .contractUpgrade: return .contractUpgrade
        case .replaceTwoFAWithStatusKeycard: return .replaceTwoFAWithStatusKeycard
        case .connectStatusKeycard: return .connectStatusKeycard
        case .disconnectStatusKeycard: return .disconnectStatusKeycard
        case .batched: return .batched
        }

    }

    private func reloadData() {
        transaction = ApplicationServiceRegistry.walletService.transactionData(transactionID)
        guard transaction != nil else {
            navigationController?.popViewController(animated: true)
            return
        }
        configureTransferDetails()
        configureType()
        configureSubmitted()
        configureStatus()
        configureFee()
        configureViewInOtherApp()
        configureActions()
        configureNonce()
        configureSafeHash()
        configureSignatures()
        configureTransactionHash()
        configureData()
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func configureTransferDetails() {
        transferView.isHidden = true
        settingsHeaderView.isHidden = false
        settingsHeaderView.fromAddress = transaction.sender
        settingsHeaderView.fromAddressName = transaction.senderName
        switch transaction.type {
        case .incoming:
            transferView.setIncoming()
            fallthrough
        case .outgoing:
            transferView.fromAddress = transaction.sender
            transferView.fromAddressName = transaction.senderName
            transferView.toAddress = transaction.recipient
            transferView.toAddressName = transaction.recipientName
            transferView.showToAddressActions = true
            transferView.tokenData = transaction.amountTokenData
            transferView.isHidden = false
            transferView.delegate = self
            settingsHeaderView.isHidden = true

            TooltipControlCenter.showFirstTimeTooltip(persistenceKey: "io.gnosis.safe.transaction_details.visited",
                                                      target: transferView.toThreeDotsButton,
                                                      parent: view,
                                                      text: LocalizedString("tap_view_options", comment: "Tap"))
        case .replaceRecoveryPhrase:
            settingsHeaderView.titleText = Strings.ReplaceRecoveryPhrase.title
            settingsHeaderView.detailText = Strings.ReplaceRecoveryPhrase.detail
        case .replaceTwoFAWithAuthenticator:
            settingsHeaderView.titleText = Strings.ReplaceTwoFA.title
            settingsHeaderView.detailText = String(format: Strings.ReplaceTwoFA.detail, Strings.gnosisSafeAuthenticator)
        case .connectAuthenticator:
            settingsHeaderView.titleText = Strings.PairTwoFA.title
            settingsHeaderView.detailText = String(format: Strings.PairTwoFA.detail, Strings.gnosisSafeAuthenticator)
        case .disconnectAuthenticator:
            settingsHeaderView.titleText = Strings.DisableTwoFA.title
            settingsHeaderView.detailText = String(format: Strings.DisableTwoFA.detail, Strings.gnosisSafeAuthenticator)
        case .contractUpgrade:
            settingsHeaderView.titleText = Strings.ContractUpgrade.title
            let safeName = ApplicationServiceRegistry.walletService.selectedWalletData.name
            settingsHeaderView.detailText = Strings.ContractUpgrade.detail(safeName: safeName)
        case .walletRecovery:
            settingsHeaderView.titleText = Strings.WalletRecovery.title
            settingsHeaderView.detailText =
                ApplicationServiceRegistry.recoveryService.isRecoveryTransactionConnectsAuthenticator(transactionID) ?
                    Strings.WalletRecovery.detailWithAuthenticator :
                Strings.WalletRecovery.detail
        case .replaceTwoFAWithStatusKeycard:
            settingsHeaderView.titleText = Strings.ReplaceTwoFA.title
            settingsHeaderView.detailText = String(format: Strings.ReplaceTwoFA.detail, Strings.statusKeyacard)
        case .connectStatusKeycard:
            settingsHeaderView.titleText = Strings.PairTwoFA.title
            settingsHeaderView.detailText = String(format: Strings.PairTwoFA.detail, Strings.statusKeyacard)
        case .disconnectStatusKeycard:
            settingsHeaderView.titleText = Strings.DisableTwoFA.title
            settingsHeaderView.detailText = String(format: Strings.DisableTwoFA.detail, Strings.statusKeyacard)
        case .batched:
            settingsHeaderView.titleText = Strings.Batched.title
            let txCount = transaction.subtransactions?.count ?? 0
            settingsHeaderView.detailText = Strings.Batched.batchedDescription(txCount)
            if txCount > 0 {
                viewButton.isHidden = false
                viewButton.style = .plain
                viewButton.setTitle(Strings.Batched.viewDetails, for: .normal)
            }
        }
        if transaction.status == .failed {
            settingsHeaderView.setFailed()
            transferView.setFailed()
        }
    }

    private func configureType() {
        transactionTypeView.name = Strings.type
        switch transaction.type {
        case .outgoing, .batched: transactionTypeView.value = Strings.outgoingType
        case .incoming: transactionTypeView.value = "" // we do not have incomming transactions yet
        case .walletRecovery, .replaceRecoveryPhrase, .replaceTwoFAWithAuthenticator, .connectAuthenticator,
             .disconnectAuthenticator, .contractUpgrade, .replaceTwoFAWithStatusKeycard, .connectStatusKeycard,
             .disconnectStatusKeycard:
            transactionTypeView.value = Strings.settingsChangeType
        }
    }

    private func configureSignatures() {
        if let signatures = transaction.signatures {
            signaturesTableView.delegate = self
            signaturesTableView.dataSource = self
            signaturesTableView.rowHeight = 60
            signatureTableViewHeightConstraint.constant = CGFloat(signatures.count * 60)
            signaturesTableView.reloadData()
            signaturesContainerView.isHidden = false
        } else {
            signaturesContainerView.isHidden = true
        }
    }

    private func configureNonce() {
        nonceView.name = "Nonce"
        if let nonce = transaction.nonce {
            nonceView.value = nonce
            nonceView.isHidden = false
        } else {
            nonceView.isHidden = true
        }
    }

    private func configureTransactionHash() {
        transactionHashView.name = "Transaction Hash"
        if let hash = transaction.transactionHash {
            transactionHashView.value = hash
            transactionHashView.isHidden = false
        } else {
            transactionHashView.isHidden = true
        }
    }

    private func configureSafeHash() {
        safeHashView.name = "Safe Hash"
        if let hash = transaction.safeHash {
            safeHashView.value = hash.toHexString()
            safeHashView.isHidden = false
        } else {
            safeHashView.isHidden = true
        }
    }

    private func configureData() {
        dataView.name = "Data"
        if let data = transaction.data {
            dataView.value = data.toHexString()
            dataView.isHidden = false
        } else {
            dataView.isHidden = true
        }
    }

    private func configureSubmitted() {
        submittedParameterView.name = Strings.submitted
        submittedParameterView.value = transaction.submitted == nil ? "--" : string(from: transaction.submitted!)
    }

    private func configureStatus() {
        transactionStatusView.name = Strings.status
        transactionStatusView.status = statusViewStatus(from: transaction.status)
        transactionStatusView.value = string(from: transaction.displayDate!)
    }

    func statusViewStatus(from status: TransactionData.Status) -> TransactionStatusParameter {
        switch status {
        case .rejected: return .rejected
        case .failed: return .failed
        case .success: return .success
        case .waitingForConfirmation: return .signing
        default: return .pending
        }
    }

    private func configureFee() {
        transactionFeeView.infoLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        transactionFeeView.infoLabel.bodyColor = ColorName.darkBlue.color
        transactionFeeView.infoLabel.setInfoText(Strings.fee)
        transactionFeeView.infoLabel.delegate = self
        transactionFeeView.amountLabel.isShowingShortFormat = true
        transactionFeeView.amountLabel.isShowingPlusSign = false
        transactionFeeView.amountLabel.hasTooltip = true
        transactionFeeView.amount = transaction.feeTokenData.withBalance(abs(transaction.feeTokenData.balance ?? 0))
    }

    private func configureViewInOtherApp() {
        let isSubmitted = transaction.status == .success ||
            transaction.status == .failed ||
            transaction.status == .pending
        viewInExternalAppButton.isHidden = !isSubmitted
        viewInExternalAppButton.setTitle(Strings.externalApp, for: .normal)
        viewInExternalAppButton.setTitleColor(ColorName.hold.color, for: .normal)
        viewInExternalAppButton.flipImageToTrailingSide(spacing: 7)
        viewInExternalAppButton.contentHorizontalAlignment = .trailing
        viewInExternalAppButton.removeTarget(self, action: nil, for: .touchUpInside)
        viewInExternalAppButton.addTarget(self, action: #selector(viewInExternalApp), for: .touchUpInside)
    }

    @objc private func viewInExternalApp() {
        delegate?.showTransactionInExternalApp(from: self)
    }

    func string(from date: Date) -> String {
        return "\(dateFormatter.string(from: date)) (\(date.timeAgo(since: clock.currentTime)))"
    }

    @IBAction func didTapViewButton(_ sender: Any) {
        let vc = WCBatchTransactionsTableViewController()
        vc.transactions = transaction.subtransactions ?? []
        navigationController?.pushViewController(vc, animated: true)
    }

    private func configureActions() {
        if transaction.status == .readyToSubmit { // if we can execute
            transactionActionsView.executeButton.isHidden = false // show execute
            transactionActionsView.approveButton.isHidden = true
        } else if transaction.status == .waitingForConfirmation, // if we signed but signatures not enough
            let signatures = transaction.signatures,
            let ourSigner = ApplicationServiceRegistry.walletService.ownerAddress(of: .personalSafe),
            signatures.contains(ourSigner) {
            transactionActionsView.executeButton.isHidden = true
            transactionActionsView.approveButton.isHidden = true
        } else if transaction.status == .waitingForConfirmation { // if  we have not signed, we need to approve
            transactionActionsView.executeButton.isHidden = true
            transactionActionsView.approveButton.isHidden = false // show approve
        } else {
            transactionActionsView.executeButton.isHidden = true
            transactionActionsView.approveButton.isHidden = true
        }
        transactionActionsView.approveButton.style = .filled
        transactionActionsView.executeButton.style = .filled
    }

    @IBAction func didTapApproveButton(_ sender: Any) {
        delegate?.transactionDetailsViewControllerDidSelectApprove(self)
    }

    @IBAction func didTapExecuteButton(_ sender: Any) {
        delegate?.transactionDetailsViewControllerDidSelectExecute(self)
    }

}

extension TransactionDetailsViewController: EventSubscriber {

    public func notify() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }

}

extension TransactionDetailsViewController: InfoLabelDelegate {

    public func didTap() {
        present(UIAlertController.networkFee(), animated: true, completion: nil)
    }

}

extension TransactionDetailsViewController: TransferViewDelegate {

    public func transferView(_ view: TransferView, didSelectActionForAddress address: String) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if ApplicationServiceRegistry.walletService.addressName(for: address) != nil {
            let editEntryAction = UIAlertAction(title: Strings.AddressEntryActions.editDetails, style: .default) {
                [unowned self] _ in
                self.delegate?.transactionDetailsViewController(self, didSelectToEditNameForAddress: address)
            }
            alertController.addAction(editEntryAction)
        } else {
            let addEntryAction = UIAlertAction(title: Strings.AddressEntryActions.addToAddressBook, style: .default) {
                [unowned self] _ in
                self.delegate?.transactionDetailsViewController(self, didSelectToEditNameForAddress: address)
            }
            alertController.addAction(addEntryAction)
        }
        let sendAgainStr = String(format: Strings.AddressEntryActions.sendTokenAgain, transaction.amountTokenData.code)
        let sendAgainAction = UIAlertAction(title: sendAgainStr, style: .default) {
            [unowned self] _ in
            self.delegate?.transactionDetailsViewController(self,
                                                            didSelectToSendToken: self.transaction.amountTokenData,
                                                            forAddress: address)
        }
        alertController.addAction(sendAgainAction)
        let cancelAction = UIAlertAction(title: Strings.AddressEntryActions.cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

}



public class TransactionActionsView: UIView {

    @IBOutlet weak var approveButton: StandardButton!
    @IBOutlet weak var executeButton: StandardButton!


}

extension TransactionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transaction.signatures?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as! AddressTableViewCell

        let signature = transaction.signatures![indexPath.row]
        cell.addressLabel.text = signature
        cell.identiconView.seed = signature
        cell.selectionStyle = .none

        return cell
    }
}


class AddressTableViewCell: UITableViewCell {
    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var addressLabel: UILabel!
}
