//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

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

    func configure(transaction: TransactionOverview) {
        transactionIconImageView.image = transaction.status.isFailed ? Asset.TransactionOverviewIcons.error.image :
            transaction.icon

        transactionTypeIconImageView.image = typeIcon(transaction)

        transactionDescriptionLabel.text = transaction.transactionDescription
        transactionDescriptionLabel.textColor = transaction.status.isFailed ? ColorName.tomato.color :
            ColorName.darkSlateBlue.color

        transactionDateLabel.text = transaction.formattedDate
        transactionDateLabel.textColor = ColorName.blueyGrey.color

        pairValueStackView.isHidden = transaction.tokenAmount == nil && transaction.fiatAmount == nil

        tokenAmountLabel.text = transaction.tokenAmount
        tokenAmountLabel.textColor = valueColor(transaction)

        fiatAmountLabel.text = transaction.fiatAmount
        fiatAmountLabel.textColor = ColorName.blueyGrey.color

        singleValueLabel.text = transaction.actionDescription
        singleValueLabel.textColor = valueColor(transaction)

        singleValueLabelStackView.isHidden = transaction.actionDescription == nil

        if case TransactionStatus.pending(let progress) = transaction.status {
            progressView.isHidden = false
            progressView.setProgress(Float(progress), animated: true)
        } else {
            progressView.isHidden = true
        }

        backgroundView?.backgroundColor = transaction.status.isFailed ? ColorName.transparentWhiteOnGrey.color :
            UIColor.white
    }

    private func typeIcon(_ transaction: TransactionOverview) -> UIImage {
        switch transaction.type {
        case .incoming: return Asset.TransactionOverviewIcons.receive.image
        case .outgoing: return Asset.TransactionOverviewIcons.sent.image
        case .settings: return Asset.TransactionOverviewIcons.settingTransactionIcon.image
        }
    }

    private func valueColor(_ transaction: TransactionOverview) -> UIColor {
        if transaction.status.isFailed { return ColorName.battleshipGrey.color }
        switch transaction.type {
        case .incoming: return ColorName.greenTeal.color
        case .outgoing: return ColorName.tomato.color
        case .settings: return ColorName.darkSlateBlue.color
        }
    }

}
