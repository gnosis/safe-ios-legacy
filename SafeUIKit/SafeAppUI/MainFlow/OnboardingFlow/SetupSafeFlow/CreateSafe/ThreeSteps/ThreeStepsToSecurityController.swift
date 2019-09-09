//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class ThreeStepsToSecurityController: NewSafeThreeStepsBaseController {

    let threeStepsToSecurityView = ThreeStepsToSecurityView()

    static func create(onNext: @escaping () -> Void) -> ThreeStepsToSecurityController {
        let controller = ThreeStepsToSecurityController(nibName: String(describing: CardViewController.self),
                                                        bundle: Bundle(for: CardViewController.self))
        controller.onNext = onNext
        return controller
    }

    enum Strings {
        static let title = LocalizedString("create_safe_title", comment: "Create Safe")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title

        threeStepsView.state = .initial
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        embed(view: threeStepsToSecurityView, inCardSubview: cardHeaderView, insets: insets)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingTrackingEvent.newSafeThreeSteps)
    }

}
