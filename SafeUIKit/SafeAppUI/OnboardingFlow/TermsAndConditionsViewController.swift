//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol TermsAndConditionsViewControllerDelegate: class {
    func wantsToOpenTermsOfUse()
    func wantsToOpenPrivacyPolicy()
    func didDisagree()
    func didAgree()
}

public class TermsAndConditionsViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var disagreeButton: UIButton!
    @IBOutlet weak var contentTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!

    public weak var delegate: TermsAndConditionsViewControllerDelegate?

    struct Strings {
        static let header = LocalizedString("onboarding.terms.header", comment: "Header label")
        static let body = LocalizedString("onboarding.terms.content",
                                          comment: "Content (bulleted list). Separate by new line characters '\n'")
        static let privacyLink = LocalizedString("onboarding.terms.privacy", comment: "Privacy Policy")
        static let termsLink = LocalizedString("onboarding.terms.terms", comment: "Terms of Use")
        static let disagree = LocalizedString("onboarding.terms.disagree", comment: "No Thanks")
        static let agree = LocalizedString("onboarding.terms.agree", comment: "Agree")
    }

    public static func create() -> TermsAndConditionsViewController {
        return StoryboardScene.MasterPassword.termsAndConditionsViewController.instantiate()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        var headerStyle = HeaderStyle.default
        headerStyle.leading = contentLeadingConstraint.constant
        headerStyle.trailing = -contentTrailingConstraint.constant
        var bodyStyle = ListStyle.default
        bodyStyle.leading = contentLeadingConstraint.constant
        bodyStyle.trailing = -contentTrailingConstraint.constant
        headerLabel.attributedText = header(from: Strings.header, style: headerStyle)
        listLabel.attributedText = list(from: Strings.body, style: bodyStyle)
        privacyPolicyButton.setAttributedTitle(link(from: Strings.privacyLink), for: .normal)
        termsOfUseButton.setAttributedTitle(link(from: Strings.termsLink), for: .normal)
        disagreeButton.setTitle(Strings.disagree, for: .normal)
        disagreeButton.setTitleColor(ColorName.aquaBlue.color, for: .normal)
        agreeButton.setTitle(Strings.agree, for: .normal)
        agreeButton.setTitleColor(ColorName.aquaBlue.color, for: .normal)
        agreeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
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

    private func link(from text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                             .font: UIFont.systemFont(ofSize: 13),
                                                             .foregroundColor: ColorName.aquaBlue.color])
    }

    private func header(from text: String, style headerStyle: HeaderStyle = .default) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = headerStyle.leading
        style.headIndent = headerStyle.leading
        style.tailIndent = -headerStyle.trailing
        style.alignment = .center
        let font = UIFont.systemFont(ofSize: headerStyle.textFontSize, weight: .medium)
        return NSAttributedString(string: text, attributes: [.paragraphStyle: style,
                                                             .font: font,
                                                             .foregroundColor: headerStyle.textColor])
    }

    private func list(from text: String, style: ListStyle = .default) -> NSAttributedString {
        return text.components(separatedBy: "\n").reduce(into: NSMutableAttributedString()) { result, text in
            result.append(listItem(from: text, style: style))
        }
    }

    private func listItem(from text: String, style listStyle: ListStyle = .default) -> NSAttributedString {
        let paragraph = "\(listStyle.bullet)\t\(text)\n"
        let style = NSMutableParagraphStyle()
        style.headIndent = listStyle.leading
        style.tailIndent = -listStyle.trailing
        // tabStop's location is the distance from previous tab stop to the start of the text
        style.tabStops = [NSTextTab(textAlignment: .left, location: listStyle.leading, options: [:])]
        style.firstLineHeadIndent = listStyle.leading - listStyle.spaceToBullet
        let str = NSMutableAttributedString(string: paragraph, attributes: [.paragraphStyle: style])
        str.addAttributes([.font: UIFont.systemFont(ofSize: listStyle.bulletFontSize),
                           .foregroundColor: listStyle.bulletColor],
                          range: (paragraph as NSString).range(of: listStyle.bullet))
        str.addAttributes([.font: UIFont.systemFont(ofSize: listStyle.textFontSize),
                           .foregroundColor: listStyle.textColor],
                          range: (paragraph as NSString).range(of: text))
        return str
    }

    struct ListStyle {
        var bullet: String
        var leading: CGFloat
        var trailing: CGFloat
        var spaceToBullet: CGFloat
        var bulletFontSize: CGFloat
        var textFontSize: CGFloat
        var textColor: UIColor
        var bulletColor: UIColor

        static let `default` = ListStyle(bullet: "•",
                                         leading: 50,
                                         trailing: 50,
                                         spaceToBullet: 18,
                                         bulletFontSize: 24,
                                         textFontSize: 14,
                                         textColor: ColorName.battleshipGrey.color,
                                         bulletColor: ColorName.whiteTwo.color)
    }

    struct HeaderStyle {
        var leading: CGFloat
        var trailing: CGFloat
        var textColor: UIColor
        var textFontSize: CGFloat

        static let `default` = HeaderStyle(leading: 50,
                                           trailing: 50,
                                           textColor: ColorName.battleshipGrey.color,
                                           textFontSize: 17)
    }

}
