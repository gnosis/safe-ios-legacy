//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class PaymentMethodFooterView: UITableViewHeaderFooterView {

    static let estimatedHeight: CGFloat = 170

    private enum Strings {
        static let payWith = LocalizedString("pay_with", comment: "Pay with %@")
        static let changePaymentMethod = LocalizedString("change_payment_method", comment: "Change payment method")
    }

    @IBOutlet weak var payWithButton: StandardButton!
    @IBOutlet weak var changeFeePaymentMethodButton: StandardButton!

    var onPay: (() -> Void)?
    var onChange: (() -> Void)?

    @IBAction func pay(_ sender: Any) {
        onPay?()
    }

    @IBAction func changePaymentMethod(_ sender: Any) {
        onChange?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        payWithButton.style = .filled
        changeFeePaymentMethodButton.style = .plain
        changeFeePaymentMethodButton.setTitle(Strings.changePaymentMethod, for: .normal)
        changeFeePaymentMethodButton.setTitleColor(ColorName.darkSkyBlue.color, for: .normal)
    }

    func setPaymentMethodCode(_ code: String) {
        payWithButton.setTitle(String(format: Strings.payWith, code), for: .normal)
    }

}
