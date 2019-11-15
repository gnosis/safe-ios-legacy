//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class PairWith2FAController: HeaderImageTextStepController {

    static func create(onNext: @escaping () -> Void,
                       onSkip: @escaping () -> Void) -> PairWith2FAController {
        let controller = PairWith2FAController(nibName: String(describing: CardViewController.self),
                                               bundle: Bundle(for: CardViewController.self))
        controller.onNext = onNext
        controller.onFooterButtonPressed = onSkip
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizedString("create_safe_title", comment: "Create Safe")
        threeStepsView.state = .pair2FA_initial
        headerImageTextView.titleLabel.text = LocalizedString("pair_safe_with_two_fa",
                                                              comment: "Pair the Safe with a 2FA device")
        headerImageTextView.imageView.image = Asset.setup2FA.image
        headerImageTextView.textLabel.text = LocalizedString("pair_safe_with_two_fa_description",
                                                             comment: "Pair with 2FA description")
        trackingEvent = CreateSafeTrackingEvent.setup2FA
        navigationItem.rightBarButtonItem?.title = LocalizedString("setup_2fa", comment: "Setup 2FA")
        footerButton.isHidden = false
        footerButton.setTitle(LocalizedString("skip_setup_later", comment: "Skip and setup later"), for: .normal)
        footerButton.addTarget(self, action: #selector(footerButtonPressed), for: .touchUpInside)
    }

}
