//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

public class CardViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var wrapperAroundContentStackView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var subtitleDetailLabel: UILabel!

    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var cardStackView: UIStackView!

    @IBOutlet weak var cardHeaderView: UIView!
    @IBOutlet weak var cardBodyView: UIView!

    @IBOutlet weak var cardSeparatorView: UIView!

    @IBOutlet weak var footerButton: StandardButton!

    public override func viewDidLoad() {
        super.viewDidLoad()
        footerButton.style = .plain
        [view,
         scrollView,
         scrollContentView,
         wrapperAroundContentStackView,
         cardSeparatorView].forEach { view in
            view?.backgroundColor = ColorName.paleGrey.color
        }
        [cardView,
         cardHeaderView,
         cardBodyView].forEach { view in
            view?.backgroundColor = .white
        }

    }

    func embed(view: UIView, inCardSubview cardSubview: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        cardSubview.addSubview(view)
        cardSubview.wrapAroundDynamicHeightView(view)
    }

    func setSubtitle(_ subtitle: String?, showError: Bool = false) {
        guard let subtitle = subtitle else {
            subtitleLabel.isHidden = true
            return
        }
        let subtitleText = NSMutableAttributedString()
        if showError {
            let attachment = NSTextAttachment(image: Asset.Onboarding.errorIcon.image,
                                              bounds: CGRect(x: 0, y: -2, width: 16, height: 16))
            subtitleText.append(attachment)
            subtitleText.append(" ")
        }
        subtitleText.append(NSAttributedString(string: subtitle, style: SubtitleStyle()))
        subtitleLabel.attributedText = subtitleText
    }

    func setSubtitleDetail(_ detail: String?) {
        guard let detail = detail else {
            subtitleDetailLabel.isHidden = true
            return
        }
        let detailText = NSMutableAttributedString(string: detail, style: SubtitleDetailStyle())
        // non-breaking space before [?]
        detailText.append(NSAttributedString(string: "\u{00A0}[?]", style: SubtitleDetailRightButtonStyle()))

        subtitleDetailLabel.attributedText = detailText
        subtitleDetailLabel.addTarget(self, action: #selector(showNetworkFeeInfo))
    }

    @objc func showNetworkFeeInfo() {
        // override
    }

    class CommonTextStyle: AttributedStringStyle {

        override var fontSize: Double { return 17 }
        override var fontWeight: UIFont.Weight { return .regular }
        override var fontColor: UIColor { return ColorName.darkSlateBlue.color }

        override var alignment: NSTextAlignment { return .center }

        override var minimumLineHeight: Double { return 22 }
        override var maximumLineHeight: Double { return 22 }


    }

    class SubtitleStyle: CommonTextStyle {

        override var fontWeight: UIFont.Weight { return .semibold }
        override var fontColor: UIColor { return ColorName.darkSlateBlue.color }

    }

    class SubtitleDetailStyle: CommonTextStyle {}

    class SubtitleDetailRightButtonStyle: CommonTextStyle {

        override var fontColor: UIColor { return ColorName.darkSkyBlue.color }

    }

}


extension NSTextAttachment {

    convenience init(image: UIImage, bounds: CGRect = .zero) {
        self.init()
        self.image = image
        self.bounds = bounds
    }

}

extension UILabel {

    func addTarget(_ target: Any?, action: Selector) {
        isUserInteractionEnabled = true
        gestureRecognizers?.compactMap { $0 }.forEach { removeGestureRecognizer($0) }
        let recognizer = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(recognizer)
    }

}

extension NSMutableAttributedString {

    func append(_ string: String) {
        self.append(NSAttributedString(string: string))
    }

    func append(_ attachment: NSTextAttachment) {
        self.append(NSAttributedString(attachment: attachment))
    }
}
