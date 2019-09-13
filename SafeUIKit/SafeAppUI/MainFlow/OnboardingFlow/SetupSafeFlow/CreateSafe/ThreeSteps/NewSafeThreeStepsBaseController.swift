//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class NewSafeThreeStepsBaseController: CardViewController {

    let threeStepsView = ThreeStepsView()
    var onNext: (() -> Void)?
    var onFooterButtonPressed: (() -> Void)?

    enum Strings {
        static let next = LocalizedString("next", comment: "Next")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        subtitleLabel.isHidden = true
        subtitleDetailLabel.isHidden = true
        cardSeparatorView.isHidden = true
        footerButton.isHidden = true

        let spacingView1 = UIView()
        spacingView1.translatesAutoresizingMaskIntoConstraints = false
        let spacingView2 = UIView()
        spacingView2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spacingView1.widthAnchor.constraint(equalToConstant: 20),
            spacingView2.widthAnchor.constraint(equalToConstant: 20)
        ])
        let threeStepsStackView = UIStackView(arrangedSubviews: [spacingView1, threeStepsView, spacingView2])
        contentStackView.insertArrangedSubview(threeStepsStackView, at: 0)
        navigationItem.rightBarButtonItem = UIBarButtonItem.nextButton(target: self, action: #selector(navigateNext))
    }

    @objc func navigateNext() {
        onNext?()
    }

    @objc func footerButtonPressed() {
        onFooterButtonPressed?()
    }

}
