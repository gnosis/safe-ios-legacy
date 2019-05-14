//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

final class PaymentMethodHeaderView: UITableViewHeaderFooterView {

    static let estimatedHeight: CGFloat = 140

    var onTextSelected: (() -> Void)?

    private enum Strings {
        static let description = LocalizedString("this_payment_will_be_used",
                                                 comment: "Fee payment method description")
        static let feeMethod = LocalizedString("fee_method", comment: "Fee Payment Method").uppercased()
        static let balance = LocalizedString("balance", comment: "Balance").uppercased()
    }

    @IBOutlet weak var descriptionInfoLabel: InfoLabel!
    @IBOutlet weak var headingView: UIView!
    @IBOutlet weak var feePaymentMethodLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIView()
        backgroundView!.backgroundColor = .white
        headingView.backgroundColor = ColorName.paleGrey.color
        descriptionInfoLabel.setInfoText(Strings.description)
        descriptionInfoLabel.delegate = self
        let headerStyle = TableHeaderStyle()
        feePaymentMethodLabel.attributedText = NSAttributedString(string: Strings.feeMethod,
                                                                  style: headerStyle)
        balanceLabel.attributedText = NSAttributedString(string: Strings.balance,
                                                         style: headerStyle)
    }

}

extension PaymentMethodHeaderView: InfoLabelDelegate {

    func didTap() {
        onTextSelected?()
    }

}
