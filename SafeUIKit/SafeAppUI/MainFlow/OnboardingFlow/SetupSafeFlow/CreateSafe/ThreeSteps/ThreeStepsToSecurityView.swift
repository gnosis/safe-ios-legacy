//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class ThreeStepsToSecurityView: BaseCustomView {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepOneLabel: UILabel!
    @IBOutlet weak var stepTwoLabel: UILabel!
    @IBOutlet weak var stepThreeLabel: UILabel!

    enum Strings {
        static let title = LocalizedString("three_steps_to_security", comment: "The three steps to security")
        static let step1 = LocalizedString("set_up_password_to_protect", comment: "Step 1 description")
        static let step2 = LocalizedString("set_up_two_fa_method", comment: "Step 2 description")
        static let step3 = LocalizedString("securely_store_your_recovery", comment: "Step 3 description")
    }

    override func commonInit() {
        safeUIKit_loadFromNib(forClass: ThreeStepsToSecurityView.self)

        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.heightAnchor.constraint(equalTo: contentStackView.heightAnchor).isActive = true
        wrapAroundDynamicHeightView(wrapperView, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

        titleLabel.text = Strings.title
        titleLabel.textColor = ColorName.darkBlue.color
        stepOneLabel.text = "1. \(Strings.step1)"
        stepOneLabel.textColor = ColorName.darkGrey.color
        stepTwoLabel.text = "2. \(Strings.step2)"
        stepTwoLabel.textColor = ColorName.darkGrey.color
        stepThreeLabel.text = "3. \(Strings.step3)"
        stepThreeLabel.textColor = ColorName.darkGrey.color
    }

}
