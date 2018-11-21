//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import SafeUIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionIconImageView: UIImageView!
    @IBOutlet weak var transactionTypeIconImageView: UIImageView!
    @IBOutlet weak var transactionDescriptionLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    @IBOutlet weak var pairValueStackView: UIStackView!
    @IBOutlet weak var fiatAmountLabel: UILabel!
    @IBOutlet weak var tokenAmountLabel: UILabel!
    @IBOutlet weak var singleValueLabelStackView: UIStackView!
    @IBOutlet weak var singleValueLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIView()
        backgroundView?.backgroundColor = UIColor.white
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 0.5)

        transactionIconImageView.layer.cornerRadius = transactionIconImageView.bounds.width / 2
        transactionIconImageView.clipsToBounds = true

        transactionTypeIconImageView.layer.cornerRadius = transactionTypeIconImageView.bounds.width / 2
        transactionTypeIconImageView.layer.borderWidth = 2
        transactionTypeIconImageView.layer.borderColor = UIColor.white.cgColor
        transactionTypeIconImageView.clipsToBounds = true
    }

    func configure(transaction: TransactionData) {
        let isFailed = transaction.status == .rejected || transaction.status == .failed
        transactionIconImageView.image = isFailed ?
            Asset.TransactionOverviewIcons.error.image :
            UIImage.createBlockiesImage(seed: transaction.recipient)

        transactionTypeIconImageView.image = typeIcon(transaction)

        transactionDescriptionLabel.text = transaction.recipient
        transactionDescriptionLabel.textColor = isFailed ? ColorName.tomato.color : ColorName.darkSlateBlue.color

        transactionDateLabel.text = transaction.displayDate?.timeAgoSinceNow
        transactionDateLabel.textColor = ColorName.blueyGrey.color

        pairValueStackView.isHidden = false

        tokenAmountLabel.text = TokenNumberFormatter
            .ERC20Token(code: transaction.amountTokenData.code, decimals: transaction.amountTokenData.decimals)
            .string(from: transaction.amount)
        tokenAmountLabel.textColor = valueColor(transaction)

        fiatAmountLabel.text = nil
        singleValueLabelStackView.isHidden = true
        progressView.isHidden = true

        backgroundView?.backgroundColor = isFailed ? ColorName.transparentWhiteOnGrey.color : UIColor.white
    }

    private func typeIcon(_ transaction: TransactionData) -> UIImage {
        switch transaction.type {
        case .outgoing: return Asset.TransactionOverviewIcons.sent.image
        }
    }

    private func valueColor(_ transaction: TransactionData) -> UIColor {
        if transaction.status == .failed { return ColorName.battleshipGrey.color }
        switch transaction.type {
        case .outgoing: return ColorName.tomato.color
        }
    }

}
