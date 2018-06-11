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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
