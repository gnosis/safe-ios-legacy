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

    private enum Strings {
        static let recoveredSafe = LocalizedString("recovered_safe", comment: "Recovered Safe")
        static let replaceRecoveryPhrase = LocalizedString("replace_recovery_phrase",
                                                           comment: "Replace recovery phrase")
        static let replaceBE = LocalizedString("replace_browser_extension", comment: "Replace browser extension")
        static let connectBE = LocalizedString("connect_browser_extension", comment: "Connect browser extension")
        static let disconnectBE = LocalizedString("disconnect_browser_extension",
                                                  comment: "Disconnect browser extension")
        static let statusFailed = LocalizedString("status_failed", comment: "Failed status")
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

        addressLabel.address = recipient(transaction)
        addressLabel.suffix = addressSuffix(transaction)
        addressLabel.textColor = addressColor(transaction)

        transactionDateLabel.text = transaction.displayDate?.timeAgoSinceNow
        transactionDateLabel.textColor = ColorName.lightGreyBlue.color

        setDetailText(transaction: transaction)
        tokenAmountLabel.textColor = valueColor(transaction)
        tokenAmountLabel.numberOfLines = 0
        tokenAmountLabel.font = UIFont.systemFont(ofSize: 16)
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
        if transaction.status == .pending { return ColorName.silver.color }
        switch transaction.type {
        case .outgoing: return ColorName.darkSlateBlue.color
        case .incoming: return ColorName.greenTeal.color
        case .walletRecovery, .replaceRecoveryPhrase,
             .replaceBrowserExtension, .connectBrowserExtension, .disconnectBrowserExtension:
            return ColorName.darkSlateBlue.color
        }
    }

}
