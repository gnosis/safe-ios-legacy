//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class FeeRequestView: BaseCustomView {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var balanceStackView: UIStackView!

    @IBOutlet weak var balanceLineStackView: UIStackView!
    @IBOutlet weak var balanceLineLabel: UILabel!
    @IBOutlet weak var balanceLineAmountLabel: AmountLabel!

    @IBOutlet weak var totalLineStackView: UIStackView!
    @IBOutlet weak var totalLineLabel: UILabel!
    @IBOutlet weak var totalLineAmountLabel: AmountLabel!

    @IBOutlet weak var feeStackView: UIStackView!
    @IBOutlet weak var feeTextLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: AmountLabel!

    override func commonInit() {
        safeUIKit_loadFromNib(forClass: FeeRequestView.self)

        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.heightAnchor.constraint(equalTo: contentStackView.heightAnchor).isActive = true
        wrapAroundDynamicHeightView(wrapperView)

        [balanceLineLabel,
        balanceLineAmountLabel,
        totalLineLabel,
        totalLineAmountLabel,
        feeTextLabel].forEach { label in
            label?.textColor = ColorName.battleshipGrey.color
        }
        feeAmountLabel.textColor = ColorName.darkSlateBlue.color
    }

}
