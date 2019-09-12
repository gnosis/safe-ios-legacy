//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class OnboardingStepViewController: UIViewController {

    private (set) var content: OnboardingStepInfo?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var topSpacingView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var moreInfoStackView: UIStackView!
    @IBOutlet weak var infoButton: StandardButton!

    @IBAction func showInfo(_ sender: Any) {
        content?.infoButtonAction?()
    }

    public static func create(content: OnboardingStepInfo?) -> OnboardingStepViewController {
        let bundle = Bundle(for: OnboardingStepViewController.self)
        let controller = OnboardingStepViewController(nibName: "OnboardingStepViewController", bundle: bundle)
        controller.content = content
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = ColorName.darkBlue.color
        titleLabel.textAlignment = .center

        infoButton.style = .text
        infoButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)

        update(content: content)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let event = content?.trackingEvent {
            trackEvent(event)
        }
    }

    func update(content: OnboardingStepInfo?) {
        self.content = content
        guard isViewLoaded else { return }
        imageView.image = content?.image
        titleLabel.text = content?.title
        descriptionLabel.text = content?.description
        descriptionLabel.attributedText = NSAttributedString(string: content?.description, style: DescriptionStyle())
        if let attributedText = content?.infoButtonText {
            infoButton.setAttributedTitle(attributedText, for: .normal)
        } else {
            moreInfoStackView.removeFromSuperview()
        }
    }

}


