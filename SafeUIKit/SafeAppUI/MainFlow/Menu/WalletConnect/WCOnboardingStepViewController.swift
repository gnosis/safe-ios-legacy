//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class WCOnboardingStepViewController: UIViewController {

    private (set) var content: WCOnboardingStepInfo?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var topSpacingView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    public static func create(content: WCOnboardingStepInfo?) -> WCOnboardingStepViewController {
        let bundle = Bundle(for: WCOnboardingStepViewController.self)
        let controller = WCOnboardingStepViewController(nibName: "WCOnboardingStepViewController", bundle: bundle)
        controller.content = content
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = ColorName.darkSlateBlue.color
        titleLabel.textAlignment = .center

        descriptionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        descriptionLabel.textColor = ColorName.battleshipGrey.color
        descriptionLabel.textAlignment = .center

        update(content: content)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let event = content?.trackingEvent {
            trackEvent(event)
        }
    }

    func update(content: WCOnboardingStepInfo?) {
        self.content = content
        imageView.image = content?.image
        titleLabel.text = content?.title
        descriptionLabel.text = content?.description
    }

}
