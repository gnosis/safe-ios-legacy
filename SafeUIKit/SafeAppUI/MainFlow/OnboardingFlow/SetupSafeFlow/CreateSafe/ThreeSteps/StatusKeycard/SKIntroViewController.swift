//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class SKIntroViewController: CardViewController {

    enum Strings {
        static let screenTitle = LocalizedString("pair_2fa_device", comment: "Pair 2FA device")
        static let header = LocalizedString("pair_your_keycard", comment: "Pair your card")
        static let body = LocalizedString("keycard_intro_description", comment: "Steps for pairing")
        static let start = LocalizedString("start", comment: "Start")
    }

    let headerImageTextView = HeaderImageTextView()
    var onStart: (() -> Void)?

    lazy var startButtonItem: UIBarButtonItem = { UIBarButtonItem(title: Strings.start,
                                                                  style: UIBarButtonItem.Style.done,
                                                                  target: self,
                                                                  action: #selector(start)) }()

    static func create(onStart: @escaping () -> Void) -> SKIntroViewController {
        let controller = SKIntroViewController(nibName: String(describing: CardViewController.self),
                                               bundle: Bundle(for: CardViewController.self))
        controller.onStart = onStart
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subtitleLabel.isHidden = true
        subtitleDetailLabel.isHidden = true
        cardSeparatorView.isHidden = true
        footerButton.isHidden = true

        let insets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        embed(view: headerImageTextView, inCardSubview: cardHeaderView, insets: insets)

        title = Strings.screenTitle
        navigationItem.rightBarButtonItem = startButtonItem
        headerImageTextView.titleLabel.text = Strings.header
        headerImageTextView.imageView.image = Asset.statusKeycardIntro.image
        headerImageTextView.textLabel.attributedText =
            NSAttributedString(list: Strings.body,
                               itemStyle: OnboardingIntroViewController.ItemAttributes(),
                               bulletStyle: OnboardingIntroViewController.BulletAttributes(),
                               nestingStyle: OnboardingIntroViewController.NestedTextAttributes())


    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(TwoFATrackingEvent.keycardIntro)
    }

    @objc func start() {
        onStart?()
    }

}
