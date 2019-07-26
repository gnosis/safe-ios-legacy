//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import DateTools
import MultisigWalletApplication
import SafeUIKit

public protocol TransactionDetailsViewControllerDelegate: class {
    func showTransactionInExternalApp(from controller: TransactionDetailsViewController)
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


        enum ReplaceRecoveryPhrase {
            static let title = LocalizedString("ios_replace_recovery_phrase", comment: "Replace recovery phrase")
                .replacingOccurrences(of: "\n", with: " ")
            static let detail = LocalizedString("layout_replace_recovery_phrase_transaction_info_description",
                                                comment: "Detail for the header in review screen")
        }
        enum ReplaceBrowserExtension {
            static let title = LocalizedString("ios_replace_browser_extension", comment: "Replace browser extension")
                .replacingOccurrences(of: "\n", with: " ")
            static let detail = LocalizedString("layout_replace_browser_extension_info_description",
                                                comment: "Detail for the header in review screen")
        }
        enum ConnectBrowserExtension {
            static let title = LocalizedString("ios_connect_browser_extension", comment: "Connect browser extension")
                .replacingOccurrences(of: "\n", with: " ")
            static let detail = LocalizedString("layout_connect_browser_extension_info_description",
                                                comment: "Detail for the header in review screen")
        }
        enum DisconnectBrowserExtension {
            static let title = LocalizedString("ios_disconnect_browser_extension",
                                               comment: "Disconnect browser extension")
                .replacingOccurrences(of: "\n", with: " ")
            static let detail = LocalizedString("layout_disconnect_browser_extension_info_description",
                                                comment: "Detail for the header in review screen")
        }
        enum WalletRecovery {
            static let title = LocalizedString("ios_recovered_safe", comment: "Recovered Safe")
                .replacingOccurrences(of: "\n", with: " ")
            static let detail = LocalizedString("layout_recovered_safe_info_description",
                                                comment: "Detail for the header in review screen")
        }
    }
    @IBOutlet weak var separatorLineView: HorizontalSeparatorView!
    @IBOutlet weak var settingsHeaderView: SettingsTransactionHeaderView!
    @IBOutlet weak var transferView: TransferView!
    @IBOutlet weak var transactionTypeView: TransactionParameterView!
    @IBOutlet weak var submittedParameterView: TransactionParameterView!
    @IBOutlet weak var transactionStatusView: StatusTransactionParameterView!
    @IBOutlet weak var transactionFeeView: TokenAmountTransactionParameterView!
    @IBOutlet weak var viewInExternalAppButton: UIButton!
    @IBOutlet weak var wrapperView: UIView!
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
        case .replaceBrowserExtension: return .replaceBrowserExtension
        case .connectBrowserExtension: return .connectBrowserExtension
        case .disconnectBrowserExtension: return .disconnectBrowserExtension
        case .walletRecovery: return .recoverSafe
        }

    }

    private func reloadData() {
        transaction = ApplicationServiceRegistry.walletService.transactionData(transactionID)
        configureTransferDetails()
        configureType()
        configureSubmitted()
        configureStatus()
        configureFee()
        configureViewInOtherApp()
    }

    private func configureTransferDetails() {
        switch transaction.type {
        case .incoming:
            transferView.setIncoming()
            fallthrough
        case .outgoing:
            transferView.fromAddress = transaction.sender
            transferView.toAddress = transaction.recipient
            transferView.tokenData = transaction.amountTokenData
            transferView.isHidden = false
            settingsHeaderView.isHidden = true
        case .replaceRecoveryPhrase:
            settingsHeaderView.titleText = Strings.ReplaceRecoveryPhrase.title
            settingsHeaderView.detailText = Strings.ReplaceRecoveryPhrase.detail
            settingsHeaderView.fromAddress = transaction.sender
            transferView.isHidden = true
            settingsHeaderView.isHidden = false
        case .replaceBrowserExtension:
            settingsHeaderView.titleText = Strings.ReplaceBrowserExtension.title
            settingsHeaderView.detailText = Strings.ReplaceBrowserExtension.detail
            settingsHeaderView.fromAddress = transaction.sender
            transferView.isHidden = true
            settingsHeaderView.isHidden = false
        case .connectBrowserExtension:
            settingsHeaderView.titleText = Strings.ConnectBrowserExtension.title
            settingsHeaderView.detailText = Strings.ConnectBrowserExtension.detail
            settingsHeaderView.fromAddress = transaction.sender
            transferView.isHidden = true
            settingsHeaderView.isHidden = false
        case .disconnectBrowserExtension:
            settingsHeaderView.titleText = Strings.DisconnectBrowserExtension.title
            settingsHeaderView.detailText = Strings.DisconnectBrowserExtension.detail
            settingsHeaderView.fromAddress = transaction.sender
            transferView.isHidden = true
            settingsHeaderView.isHidden = false
        case .walletRecovery:
            settingsHeaderView.titleText = Strings.WalletRecovery.title
            settingsHeaderView.detailText = Strings.WalletRecovery.detail
            settingsHeaderView.fromAddress = transaction.sender
            transferView.isHidden = true
            settingsHeaderView.isHidden = false
        }
        if transaction.status == .failed {
            settingsHeaderView.setFailed()
            transferView.setFailed()
        }
    }

    private func configureType() {
        transactionTypeView.name = Strings.type
        switch transaction.type {
        case .outgoing: transactionTypeView.value = Strings.outgoingType
        case .incoming: transactionTypeView.value = "" // we do not have incomming transactions yet
        case .walletRecovery, .replaceRecoveryPhrase, .replaceBrowserExtension, .connectBrowserExtension,
             .disconnectBrowserExtension: transactionTypeView.value = Strings.settingsChangeType
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
        default: return .pending
        }
    }

    private func configureFee() {
        transactionFeeView.infoLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        transactionFeeView.infoLabel.bodyColor = ColorName.darkBlue.color
        transactionFeeView.infoLabel.setInfoText(Strings.fee)
        transactionFeeView.infoLabel.delegate = self
        transactionFeeView.amountLabel.isShowingShortFormat = true
        transactionFeeView.amountLabel.hasTooltip = true
        transactionFeeView.amount = transaction.feeTokenData.withBalance(-abs(transaction.feeTokenData.balance ?? 0))
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
