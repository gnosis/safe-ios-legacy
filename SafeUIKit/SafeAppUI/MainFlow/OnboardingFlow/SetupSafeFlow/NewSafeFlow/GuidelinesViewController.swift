//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common
import SafeUIKit

public protocol GuidelinesViewControllerDelegate: class {
    func didPressNext()
}

public class GuidelinesViewController: UIViewController {

    var titleText: String? {
        didSet {
            update()
        }
    }
    var headerText: String? {
        didSet {
            update()
        }
    }
    var headerImage: UIImage? {
        didSet {
            update()
        }
    }
    var bodyText: String? {
        didSet {
            update()
        }
    }
    var nextActionText: String? {
        didSet {
            update()
        }
    }

    @IBOutlet var backgroundView: BackgroundImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextButtonItem: UIBarButtonItem!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!

    var bodyStyle = ListStyle.default
    public weak var delegate: GuidelinesViewControllerDelegate?
    /// If not nil, then will be tracked, otherwise default onboarding events will be tracked.
    var screenTrackingEvent: Trackable?

    public static func create(delegate: GuidelinesViewControllerDelegate? = nil) -> GuidelinesViewController {
        let controller = StoryboardScene.NewSafe.guidelinesViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.isWhite = true
        bodyStyle.bulletColor = ColorName.aquaBlue.color
        bodyStyle.textColor = ColorName.battleshipGrey.color
        bodyStyle.textFontSize = 16
        update()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let event = screenTrackingEvent {
            trackEvent(event)
        } else {
            trackEvent(OnboardingEvent.guidelines)
            trackEvent(OnboardingTrackingEvent.recoveryIntro)
        }
    }

    func update() {
        guard isViewLoaded else { return }
        navigationItem.titleView = SafeLabelTitleView.onboardingTitleView(text: titleText)
        headerLabel.attributedText = NSAttributedString(string: headerText, style: OnboardingHeaderStyle())
        contentLabel.attributedText = .list(from: bodyText, style: bodyStyle)
        nextButtonItem.title = nextActionText
        imageView.image = headerImage
        imageView.isHidden = headerImage == nil
    }

    @IBAction func proceed(_ sender: Any) {
        delegate?.didPressNext()
    }

}

class OnboardingHeaderStyle: AttributedStringStyle {

    override var fontSize: Double { return 17 }
    override var maximumLineHeight: Double { return 22 }
    override var minimumLineHeight: Double { return 22 }
    override var alignment: NSTextAlignment { return .center }
    override var fontColor: UIColor { return ColorName.darkSlateBlue.color }
    override var fontWeight: UIFont.Weight { return .semibold }

}

extension SafeLabelTitleView {

    static func onboardingTitleView(text: String?) -> SafeLabelTitleView {
        let view = SafeLabelTitleView()
        view.attributedText = NSAttributedString(string: text, style: OnboardingHeaderStyle())
        return view
    }

}
