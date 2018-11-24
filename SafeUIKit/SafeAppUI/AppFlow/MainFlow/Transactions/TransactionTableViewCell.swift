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
        identiconView.seed = transaction.recipient

        addressLabel.address = transaction.recipient
        addressLabel.suffix = addressSuffix(transaction)
        addressLabel.textColor = addressColor(transaction)

        transactionDateLabel.text = transaction.displayDate?.timeAgoSinceNow
        transactionDateLabel.textColor = ColorName.blueyGrey.color

        tokenAmountLabel.amount = transaction.amountTokenData
        tokenAmountLabel.textColor = valueColor(transaction)
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
        }
    }

}

public class EthereumAddressLabel: BaseCustomLabel {

    public var formatter = EthereumAddressFormatter()

    public var address: String? {
        didSet {
            update()
        }
    }

    public var suffix: String? {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        formatter.hexMode = .mixedcased
        formatter.truncationMode = .middle
        formatter.usesHeadTailSplit = true
        formatter.headLength = 2
        formatter.tailLength = 4
        update()
    }

    public override func update() {
        guard let address = address else {
            text = nil
            return
        }
        text = [formatter.string(from: address), suffix].compactMap { $0 }.joined(separator: " ")
    }

}

public class AmountLabel: BaseCustomLabel {

    public var formatter = TokenNumberFormatter.ERC20Token(decimals: 18)

    public var amount: TokenData? {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        formatter.plusSign = "+ "
        formatter.minusSign = "- "
        update()
    }

    public override func update() {
        guard let amount = amount else {
            text = nil
            return
        }
        formatter.tokenCode = amount.code
        formatter.decimals = amount.decimals
        text = formatter.string(from: amount.balance ?? 0)
    }

}
