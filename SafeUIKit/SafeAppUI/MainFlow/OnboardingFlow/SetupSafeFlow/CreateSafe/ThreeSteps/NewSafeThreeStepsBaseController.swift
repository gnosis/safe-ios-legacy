//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class NewSafeThreeStepsBaseController: CardViewController {

    let threeStepsView = ThreeStepsView()
    var onNext: (() -> Void)?

    enum Strings {
        static let next = LocalizedString("next", comment: "Next")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        subtitleLabel.isHidden = true
        subtitleDetailLabel.isHidden = true
        cardSeparatorView.isHidden = true
        footerButton.isHidden = true

        contentStackView.insertArrangedSubview(threeStepsView, at: 0)
        navigationItem.rightBarButtonItem = UIBarButtonItem.nextButton(target: self, action: #selector(navigateNext))
    }

    @objc private func navigateNext() {
        onNext?()
    }

}
