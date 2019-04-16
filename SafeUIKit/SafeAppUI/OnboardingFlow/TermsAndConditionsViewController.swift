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

    public weak var delegate: TermsAndConditionsViewControllerDelegate?

    private enum Strings {
        static let header = LocalizedString("please_review_terms_and_privacy_policy", comment: "Header label")
        static let body = LocalizedString("ios_terms_contents",
                                          comment: "Content (bulleted list). Separate by new line characters '\n'")
        static let privacyLink = LocalizedString("ios_privacy_policy_link_text", comment: "Privacy Policy")
        static let termsLink = LocalizedString("ios_terms_link_text", comment: "Terms of Use")
        static let disagree = LocalizedString("no_thanks", comment: "No Thanks")
        static let agree = LocalizedString("agree", comment: "Agree")
    }

    public static func create() -> TermsAndConditionsViewController {
        return StoryboardScene.MasterPassword.termsAndConditionsViewController.instantiate()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let headerStyle = HeaderStyle.default
        var bodyStyle = ListStyle.default
        bodyStyle.minimumLineHeight = 0
        bodyStyle.paragraphSpacing = 0
        headerLabel.attributedText = .header(from: Strings.header, style: headerStyle)
        listLabel.attributedText = .list(from: Strings.body, style: bodyStyle)
        privacyPolicyButton.setAttributedTitle(link(from: Strings.privacyLink), for: .normal)
        termsOfUseButton.setAttributedTitle(link(from: Strings.termsLink), for: .normal)
        disagreeButton.setTitle(Strings.disagree, for: .normal)
        disagreeButton.setTitleColor(ColorName.aquaBlue.color, for: .normal)
        agreeButton.setTitle(Strings.agree, for: .normal)
        agreeButton.setTitleColor(ColorName.aquaBlue.color, for: .normal)
        agreeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
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

    private func link(from text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                             .font: UIFont.systemFont(ofSize: 13),
                                                             .foregroundColor: ColorName.aquaBlue.color])
    }

}

struct BodyStyle {

    var textFontSize: CGFloat
    var textColor: UIColor
    var fontWeight: UIFont.Weight
    var alignment: NSTextAlignment
    var paragraphSpacing: CGFloat
    var minimumLineHeight: CGFloat

    static let `default` = BodyStyle(textFontSize: 16,
                                     textColor: ColorName.battleshipGrey.color,
                                     fontWeight: .regular,
                                     alignment: .left,
                                     paragraphSpacing: 21,
                                     minimumLineHeight: 25)

    static let emphasis = BodyStyle(textFontSize: BodyStyle.default.textFontSize,
                                    textColor: BodyStyle.default.textColor,
                                    fontWeight: .semibold,
                                    alignment: BodyStyle.default.alignment,
                                    paragraphSpacing: BodyStyle.default.paragraphSpacing,
                                    minimumLineHeight: BodyStyle.default.minimumLineHeight)

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
    var paragraphSpacing: CGFloat
    var minimumLineHeight: CGFloat

    static let `default` = ListStyle(bullet: "•",
                                     leading: 40,
                                     trailing: 40,
                                     spaceToBullet: 18,
                                     bulletFontSize: 24,
                                     textFontSize: 14,
                                     textColor: ColorName.battleshipGrey.color,
                                     bulletColor: ColorName.whiteTwo.color,
                                     paragraphSpacing: 22,
                                     minimumLineHeight: 25)
}

struct HeaderStyle {
    var leading: CGFloat
    var trailing: CGFloat
    var textColor: UIColor
    var textFontSize: CGFloat

    static let `default` = HeaderStyle(leading: 40,
                                       trailing: 40,
                                       textColor: ColorName.battleshipGrey.color,
                                       textFontSize: 17)

    static let contentHeader = HeaderStyle(leading: 40,
                                           trailing: 40,
                                           textColor: ColorName.darkSlateBlue.color,
                                           textFontSize: 20)
}

extension NSAttributedString {

    static func body(from text: String?, style bodyStyle: BodyStyle = .default) -> NSAttributedString? {
        guard let text = text else { return nil }
        let style = NSMutableParagraphStyle()
        style.alignment = bodyStyle.alignment
        style.paragraphSpacing = bodyStyle.paragraphSpacing
        style.minimumLineHeight = bodyStyle.minimumLineHeight
        let font = UIFont.systemFont(ofSize: bodyStyle.textFontSize, weight: bodyStyle.fontWeight)
        return NSAttributedString(string: text, attributes: [.paragraphStyle: style,
                                                             .font: font,
                                                             .foregroundColor: bodyStyle.textColor])
    }

    static func header(from text: String?, style headerStyle: HeaderStyle = .default) -> NSAttributedString? {
        guard let text = text else { return nil }
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = headerStyle.leading
        style.headIndent = headerStyle.leading
        style.tailIndent = -headerStyle.trailing
        style.alignment = .center
        let font = UIFont.systemFont(ofSize: headerStyle.textFontSize, weight: .bold)
        return NSAttributedString(string: text, attributes: [.paragraphStyle: style,
                                                             .font: font,
                                                             .foregroundColor: headerStyle.textColor])
    }

    static func list(from text: String?, style: ListStyle = .default) -> NSAttributedString? {
        guard let text = text else { return nil }
        return text.components(separatedBy: "\n").reduce(into: NSMutableAttributedString()) { result, text in
            result.append(listItem(from: text, style: style))
        }
    }

    static func listItem(from text: String, style listStyle: ListStyle = .default) -> NSAttributedString {
        let paragraph = "\(listStyle.bullet)\t\(text)\n"
        let style = NSMutableParagraphStyle()
        style.headIndent = listStyle.leading
        style.tailIndent = -listStyle.trailing
        // tabStop's location is the distance from previous tab stop to the start of the text
        style.tabStops.insert(NSTextTab(textAlignment: .left, location: listStyle.leading, options: [:]), at: 0)
        style.firstLineHeadIndent = listStyle.leading - listStyle.spaceToBullet
        style.paragraphSpacing = listStyle.paragraphSpacing
        style.minimumLineHeight = listStyle.minimumLineHeight
        let str = NSMutableAttributedString(string: paragraph, attributes: [.paragraphStyle: style])
        str.addAttributes([.font: UIFont.systemFont(ofSize: listStyle.bulletFontSize),
                           .foregroundColor: listStyle.bulletColor],
                          range: (paragraph as NSString).range(of: listStyle.bullet))
        str.addAttributes([.font: UIFont.systemFont(ofSize: listStyle.textFontSize),
                           .foregroundColor: listStyle.textColor],
                          range: (paragraph as NSString).range(of: text))
        return str
    }

}
