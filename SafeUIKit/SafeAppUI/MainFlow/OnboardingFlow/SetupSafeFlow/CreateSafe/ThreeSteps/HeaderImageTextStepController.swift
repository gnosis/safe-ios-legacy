//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common
import SafeUIKit

class HeaderImageTextStepController: NewSafeThreeStepsBaseController {

    let headerImageTextView = HeaderImageTextView()
    var trackingEvent: ScreenTrackingEvent!

    static func create(title: String,
                       threeStepsState: ThreeStepsView.State,
                       header: String,
                       image: UIImage,
                       text: String,
                       trackingEvent: ScreenTrackingEvent,
                       onNext: @escaping () -> Void) -> HeaderImageTextStepController {
        let controller = HeaderImageTextStepController(nibName: String(describing: CardViewController.self),
                                                       bundle: Bundle(for: CardViewController.self))
        controller.title = title
        controller.threeStepsView.state = threeStepsState
        controller.headerImageTextView.titleLabel.text = header
        controller.headerImageTextView.imageView.image = image
        controller.headerImageTextView.textLabel.text = text
        controller.trackingEvent = trackingEvent
        controller.onNext = onNext
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let insets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        embed(view: headerImageTextView, inCardSubview: cardHeaderView, insets: insets)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(trackingEvent)
    }

}
