//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import SafeUIKit
import Common

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var addressLabel: EthereumAddressLabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    @IBOutlet weak var tokenAmountLabel: AmountLabel!
    @IBOutlet weak var transactionTypeImageView: UIImageView!

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        f.locale = .autoupdatingCurrent
        return f
    }()

    enum Strings {
        static let recoveredSafe = LocalizedString("ios_recovered_safe", comment: "Recovered Safe")
        static let replaceRecoveryPhrase = LocalizedString("ios_replace_recovery_phrase",
                                                           comment: "Replace recovery phrase")
        static let replaceBE = LocalizedString("ios_replace_browser_extension", comment: "Replace browser extension")
        static let connectBE = LocalizedString("ios_connect_browser_extension", comment: "Connect browser extension")
        static let disconnectBE = LocalizedString("ios_disconnect_browser_extension",
                                                  comment: "Disconnect browser extension")
        static let statusFailed = LocalizedString("status_failed", comment: "Failed status")
        static let timeJustNow = LocalizedString("just_now", comment: "Time indication of 'Just now'")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIView()
        backgroundView?.backgroundColor = UIColor.white
        identiconView.layer.cornerRadius = identiconView.bounds.width / 2
        identiconView.clipsToBounds = true
    }

    func configure(transaction: TransactionData) {
        identiconView.seed = recipient(transaction)
        if transaction.status == .failed {
            identiconView.imageView.image = Asset.TransactionOverviewIcons.error.image
        }

        addressLabel.address = recipient(transaction)
        addressLabel.suffix = addressSuffix(transaction)
        addressLabel.textColor = addressColor(transaction)
        addressLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        transactionDateLabel.text = dateText(transaction)
        transactionDateLabel.textColor = ColorName.battleshipGrey.color
        transactionDateLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)

        setDetailText(transaction: transaction)
        tokenAmountLabel.textColor = valueColor(transaction)
        tokenAmountLabel.numberOfLines = 0
        tokenAmountLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tokenAmountLabel.textAlignment = .right

        transactionTypeImageView.image = typeImage(transaction)
    }

    private func dateText(_ transaction: TransactionData) -> String? {
        guard let date = transaction.displayDate else { return nil }
        let isInTheFuture = date > Date()
        if date.minutesAgo == 0 && !isInTheFuture {
            return Strings.timeJustNow
        } else if date.isToday && !isInTheFuture {
            return date.timeAgoSinceNow
        } else {
            return type(of: self).timeFormatter.string(from: date)
        }
    }

    private func setDetailText(transaction tx: TransactionData) {
        switch tx.type {
        case .incoming, .outgoing:
            tokenAmountLabel.amount = tx.amountTokenData
        case .walletRecovery:
            tokenAmountLabel.text = Strings.recoveredSafe
        case .replaceRecoveryPhrase:
            tokenAmountLabel.text = Strings.replaceRecoveryPhrase
        case .replaceBrowserExtension:
            tokenAmountLabel.text = Strings.replaceBE
        case .connectBrowserExtension:
            tokenAmountLabel.text = Strings.connectBE
        case .disconnectBrowserExtension:
            tokenAmountLabel.text = Strings.disconnectBE
        }
    }

    private func recipient(_ transaction: TransactionData) -> String {
        switch transaction.type {
        case .incoming, .walletRecovery, .replaceRecoveryPhrase,
             .replaceBrowserExtension, .connectBrowserExtension, .disconnectBrowserExtension:
            return transaction.sender
        case .outgoing: return transaction.recipient
        }
    }

    private func addressSuffix(_ transaction: TransactionData) -> String? {
        switch transaction.status {
        case .failed: return "(\(Strings.statusFailed.lowercased()))"
        default: return nil
        }
    }

    private func addressColor(_ transaction: TransactionData) -> UIColor {
        switch transaction.status {
        case .rejected, .failed: return ColorName.tomato.color
        default: return ColorName.darkSlateBlue.color
        }
    }

    private func valueColor(_ transaction: TransactionData) -> UIColor {
        if transaction.status == .pending || transaction.status == .failed {
            return ColorName.lightGreyBlue.color
        }
        switch transaction.type {
        case .outgoing: return ColorName.darkSlateBlue.color
        case .incoming: return ColorName.greenTeal.color
        case .walletRecovery, .replaceRecoveryPhrase,
             .replaceBrowserExtension, .connectBrowserExtension, .disconnectBrowserExtension:
            return ColorName.darkSlateBlue.color
        }
    }

    private func typeImage(_ transaction: TransactionData) -> UIImage {
        switch transaction.type {
        case .outgoing: return Asset.TransactionOverviewIcons.iconOutgoing.image
        case .incoming: return Asset.TransactionOverviewIcons.iconIncoming.image
        case .walletRecovery, .replaceRecoveryPhrase,
             .replaceBrowserExtension, .connectBrowserExtension, .disconnectBrowserExtension:
            return Asset.TransactionOverviewIcons.iconSettings.image
        }
    }

}
