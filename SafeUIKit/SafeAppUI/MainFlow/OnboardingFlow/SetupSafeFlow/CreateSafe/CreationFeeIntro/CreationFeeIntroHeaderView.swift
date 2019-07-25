//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class CreationFeeIntroHeaderView: UITableViewHeaderFooterView {

    static let estimatedHeight: CGFloat = 185

    var onTextSelected: (() -> Void)?

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionInfoLabel: InfoLabel!
    @IBOutlet weak var headingView: UIView!
    @IBOutlet weak var feePaymentMethodLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!

    private enum Strings {
        static let header = LocalizedString("safe_creation_fee", comment: "Safe creation fee")
        static let description = LocalizedString("network_fee_required", comment: "Network fee description")
        static let feeMethod = LocalizedString("fee_method", comment: "Fee payment method").uppercased()
        static let fee = LocalizedString("fee", comment: "Fee").uppercased()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIView()
        backgroundView!.backgroundColor = ColorName.snowwhite.color
        headingView.backgroundColor = ColorName.white.color
        headerLabel.text = Strings.header
        headerLabel.textColor = ColorName.darkBlue.color
        descriptionInfoLabel.setInfoText(Strings.description)
        descriptionInfoLabel.delegate = self
        let headerStyle = TableHeaderStyle()
        feePaymentMethodLabel.attributedText = NSAttributedString(string: Strings.feeMethod,
                                                                  style: headerStyle)
        feeLabel.attributedText = NSAttributedString(string: Strings.fee,
                                                     style: headerStyle)
    }

}

extension CreationFeeIntroHeaderView: InfoLabelDelegate {

    func didTap() {
        onTextSelected?()
    }

}
