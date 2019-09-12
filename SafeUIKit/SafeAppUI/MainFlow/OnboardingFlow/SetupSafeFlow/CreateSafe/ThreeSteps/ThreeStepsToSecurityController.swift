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

        navigationItem.title = Strings.title

        threeStepsView.state = .initial
        embed(view: threeStepsToSecurityView, inCardSubview: cardHeaderView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(CreateSafeTrackingEvent.threeSteps)
    }

}
