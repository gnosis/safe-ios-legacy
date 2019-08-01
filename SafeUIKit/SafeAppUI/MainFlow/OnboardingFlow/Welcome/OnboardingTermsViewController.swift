//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

public protocol OnboardingTermsViewControllerDelegate: class {
    func wantsToOpenTermsOfUse()
    func wantsToOpenPrivacyPolicy()
    func didDisagree()
    func didAgree()
}

public class OnboardingTermsViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var agreeButton: StandardButton!
    @IBOutlet weak var disagreeButton: StandardButton!

    public weak var delegate: OnboardingTermsViewControllerDelegate?

    private enum Strings {
        static let header = LocalizedString("please_review_terms_and_privacy_policy", comment: "Header label")
        static let body = LocalizedString("ios_terms_contents",
                                          comment: "Each bullet starts with '* '. Separated by newline '\n'.")
        static let privacyLink = LocalizedString("privacy_policy", comment: "Privacy Policy")
        static let termsLink = LocalizedString("terms_of_service", comment: "Terms of Use")
        static let disagree = LocalizedString("no_thanks", comment: "No Thanks")
        static let agree = LocalizedString("agree", comment: "Agree")
    }

    public static func create() -> OnboardingTermsViewController {
        return StoryboardScene.MasterPassword.onboardingTermsViewController.instantiate()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        headerLabel.attributedText = NSAttributedString(string: Strings.header, style: HeaderStyle())
        listLabel.attributedText = NSAttributedString(list: Strings.body,
                                                      itemStyle: ItemAttributes(),
                                                      bulletStyle: BulletAttributes(),
                                                      nestingStyle: NestedTextAttributes())


        let linkStyle = LinkStyle()
        privacyPolicyButton.setAttributedTitle(NSAttributedString(string: Strings.privacyLink, style: linkStyle),
                                               for: .normal)
        termsOfUseButton.setAttributedTitle(NSAttributedString(string: Strings.termsLink, style: linkStyle),
                                            for: .normal)
        [privacyPolicyButton, termsOfUseButton].forEach { button in
            button!.addUnderline(color: linkStyle.fontColor, width: 1.0, offset: 0, pattern: nil)
        }

        agreeButton.setTitle(Strings.agree, for: .normal)
        agreeButton.style = .filled

        disagreeButton.setTitle(Strings.disagree, for: .normal)
        disagreeButton.style = .plain
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingTrackingEvent.terms)
    }

    @IBAction func openTermsOfUse(_ sender: Any) {
        delegate?.wantsToOpenTermsOfUse()
    }

    @IBAction func openPrivacyPolicy(_ sender: Any) {
        delegate?.wantsToOpenPrivacyPolicy()
    }

    @IBAction func disagree(_ sender: Any) {
        delegate?.didDisagree()
    }

    @IBAction func agree(_ sender: Any) {
        delegate?.didAgree()
    }

    @IBAction func didTapBackground(_ sender: Any) {
        delegate?.didDisagree()
    }

    private func link(from text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                             .font: UIFont.systemFont(ofSize: 15),
                                                             .foregroundColor: ColorName.hold.color])
    }

    class LinkStyle: AttributedStringStyle {

        override var fontSize: Double { return 15 }
        override var fontColor: UIColor { return ColorName.hold.color }
        override var minimumLineHeight: Double { return 20 }
        override var maximumLineHeight: Double { return 20 }

    }

    class HeaderStyle: AttributedStringStyle {

        override var fontSize: Double { return 17 }
        override var fontColor: UIColor { return ColorName.darkBlue.color }
        override var fontWeight: UIFont.Weight { return .medium }
        override var minimumLineHeight: Double { return 22 }
        override var maximumLineHeight: Double { return 22 }
        override var alignment: NSTextAlignment { return .center }

    }

    class ItemAttributes: AttributedStringStyle {

        override var fontSize: Double { return 15 }
        override var minimumLineHeight: Double { return 20 }
        override var maximumLineHeight: Double { return 20 }
        override var tabStopInterval: Double { return 26 }
        override var spacingBeforeParagraph: Double { return 12 }
        override var fontColor: UIColor { return ColorName.darkGrey.color }

    }

    class BulletAttributes: ItemAttributes {

        override var fontColor: UIColor { return ColorName.hold.color }
        override var fontSize: Double { return 19 }
        override var nonFirstLinesHeadIndent: Double { return tabStopInterval }

    }

    class NestedTextAttributes: ItemAttributes {

        override var spacingBeforeParagraph: Double { return 0 }

    }

}
