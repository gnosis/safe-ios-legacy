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
        descriptionInfoLabel.delegate = self
        updateDescriptionLabel(Strings.description)
        feePaymentMethodLabel.attributedText = NSAttributedString(string: Strings.feeMethod,
                                                                  style: TableHeaderStyle())
        updateBalanceLabel(Strings.balance)
    }

    func updateDescriptionLabel(_ text: String, withInfo: Bool = true) {
        descriptionInfoLabel.setInfoText(text, withInfo: withInfo)
    }

    func updateBalanceLabel(_ text: String) {
        balanceLabel.attributedText = NSAttributedString(string: text,
                                                         style: TableHeaderStyle())
    }

}

extension PaymentMethodHeaderView: InfoLabelDelegate {

    func didTap() {
        onTextSelected?()
    }

}
