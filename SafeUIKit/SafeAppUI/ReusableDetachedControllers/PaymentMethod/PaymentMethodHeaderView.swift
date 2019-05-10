//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

final class PaymentMethodHeaderView: UITableViewHeaderFooterView {

    static let estimatedHeight: CGFloat = 140

    @IBOutlet weak var descriptionInfoLabel: InfoLabel!
    @IBOutlet weak var headingView: UIView!
    @IBOutlet weak var feePaymentMethodLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIView()
        backgroundView!.backgroundColor = .white
        headingView.backgroundColor = ColorName.paleGrey.color
        descriptionInfoLabel.setInfoText("A network fee is required to create your new Safe.")
        descriptionInfoLabel.delegate = self
        let headingAttributes: [NSAttributedString.Key: Any] =
            [.font: UIFont.systemFont(ofSize: 10, weight: .bold),
             .foregroundColor: ColorName.lightGreyBlue.color,
             .kern: 2]
        feePaymentMethodLabel.attributedText = NSAttributedString(string: "FEE PAYMENT METHOD",
                                                                  attributes: headingAttributes)
        balanceLabel.attributedText = NSAttributedString(string: "BALANCE",
                                                         attributes: headingAttributes)
    }

}

extension PaymentMethodHeaderView: InfoLabelDelegate {

    func didTap() {
        print("DID TAP")
    }

}
