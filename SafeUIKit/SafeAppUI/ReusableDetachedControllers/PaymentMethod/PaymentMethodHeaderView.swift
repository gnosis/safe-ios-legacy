//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

final class PaymentMethodHeaderView: UITableViewHeaderFooterView {

    static let height: CGFloat = 100

    @IBOutlet weak var descriptionInfoLabel: InfoLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        descriptionInfoLabel.setInfoText("A network fee is required to create your new Safe.")
        descriptionInfoLabel.delegate = self
    }

}

extension PaymentMethodHeaderView: InfoLabelDelegate {

    func didTap() {
        print("DID TAP")
    }

}
