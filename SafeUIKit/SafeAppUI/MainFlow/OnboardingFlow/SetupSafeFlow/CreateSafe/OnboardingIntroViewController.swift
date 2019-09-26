//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common
import SafeUIKit

public protocol OnboardingIntroViewControllerDelegate: class {
    func didPressNext()
    func didGoBack()
}

public class OnboardingIntroViewController: UIViewController {

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
    var backButtonItem: UIBarButtonItem!

    public weak var delegate: OnboardingIntroViewControllerDelegate?
    /// If not nil, then will be tracked, otherwise default onboarding events will be tracked.
    var screenTrackingEvent: Trackable?

    public static func create(delegate: OnboardingIntroViewControllerDelegate? = nil) -> OnboardingIntroViewController {
        let controller = StoryboardScene.CreateSafe.onboardingIntroViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.isWhite = true
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
        contentLabel.attributedText = NSAttributedString(list: bodyText ?? "",
                                                         itemStyle: ItemAttributes(),
                                                         bulletStyle: BulletAttributes(),
                                                         nestingStyle: NestedTextAttributes())
        nextButtonItem.title = nextActionText
        imageView.image = headerImage
        imageView.isHidden = headerImage == nil
    }

    public override func willMove(toParent parent: UIViewController?) {
        backButtonItem = UIBarButtonItem.backButton(target: self, action: #selector(back))
        setCustomBackButton(backButtonItem)
    }

    @objc func back() {
        delegate?.didGoBack()
    }

    @IBAction func proceed(_ sender: Any) {
        delegate?.didPressNext()
    }

    class ItemAttributes: AttributedStringStyle {

        override var fontSize: Double { return 17 }
        override var minimumLineHeight: Double { return 22 }
        override var maximumLineHeight: Double { return 22 }
        override var tabStopInterval: Double { return 20 }
        override var spacingBeforeParagraph: Double { return 18 }
        override var fontColor: UIColor { return ColorName.darkGrey.color }

        let bulletWidth: Double = 6
        let edgeMargin: Double = 16

        override var firstLineHeadIndent: Double { return edgeMargin }

        override var nonFirstLinesHeadIndent: Double {
            return  edgeMargin + bulletWidth + tabStopInterval
        }

        override var allLinesTailIndent: Double { return -edgeMargin }

    }

    class BulletAttributes: ItemAttributes {

        override var fontColor: UIColor { return ColorName.hold.color }
        override var fontSize: Double { return 19 }

    }

    class NestedTextAttributes: ItemAttributes {

        override var spacingBeforeParagraph: Double { return bulletWidth }
        override var nonFirstLinesHeadIndent: Double { return super.nonFirstLinesHeadIndent + tabStopInterval }
    }

}

class OnboardingHeaderStyle: AttributedStringStyle {

    override var fontSize: Double { return 17 }
    override var maximumLineHeight: Double { return 22 }
    override var minimumLineHeight: Double { return 22 }
    override var alignment: NSTextAlignment { return .center }
    override var fontColor: UIColor { return ColorName.darkBlue.color }
    override var fontWeight: UIFont.Weight { return .semibold }

}

extension SafeLabelTitleView {

    static func onboardingTitleView(text: String?) -> SafeLabelTitleView {
        let view = SafeLabelTitleView()
        view.attributedText = NSAttributedString(string: text, style: OnboardingHeaderStyle())
        return view
    }

}

extension OnboardingIntroViewController: InteractivePopGestureResponder {

    func interactivePopGestureShouldBegin() -> Bool {
        return false
    }

}
