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
        transactionDateLabel.textColor = ColorName.blueyGrey.color

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
            tokenAmountLabel.text = LocalizedString("transactions.row.wallet_recovery",
                                                    comment: "Wallet recovered")
        case .replaceRecoveryPhrase:
            tokenAmountLabel.text = LocalizedString("transactions.row.replace_phrase",
                                                    comment: "Recovery phrase changed")
        case .replaceBrowserExtension:
            tokenAmountLabel.text = LocalizedString("transactions.row.replace_extension",
                                                    comment: "Browser extension changed")
        }
    }

    private func recipient(_ transaction: TransactionData) -> String {
        switch transaction.type {
        case .incoming, .walletRecovery, .replaceRecoveryPhrase, .replaceBrowserExtension: return transaction.sender
        case .outgoing: return transaction.recipient
        }
    }

    private func addressSuffix(_ transaction: TransactionData) -> String? {
        switch transaction.status {
        case .rejected: return LocalizedString("transactions.row.rejected", comment: "(rejected) suffix")
        case .failed: return LocalizedString("transactions.row.failed", comment: "(failed) suffix)")
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
        case .walletRecovery, .replaceRecoveryPhrase, .replaceBrowserExtension:
            return ColorName.darkSlateBlue.color
        }
    }

}
