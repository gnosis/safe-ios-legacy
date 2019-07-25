//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol InfoLabelDelegate: class {
    func didTap()
}

public class InfoLabel: BaseCustomLabel {

    public weak var delegate: InfoLabelDelegate?

    public var infoSuffix = "[?]"
    public var infoColor: UIColor = ColorName.hold.color
    public var bodyColor: UIColor = ColorName.darkGrey.color

    public override func commonInit() {
        font = UIFont.systemFont(ofSize: 17)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapRecognizer)
        isUserInteractionEnabled = true
    }

    @objc private func didTap() {
        delegate?.didTap()
    }

    public func setInfoText(_ text: String, withInfo: Bool = true) {
        // Non-braking space is used with info suffix to make it always next to the last word when the line splits.
        let str = withInfo ? "\(text)\u{00A0}\(infoSuffix)" : text
        let attributedString = NSMutableAttributedString(string: str)
        let textRange = attributedString.mutableString.range(of: text)
        let infoRange = attributedString.mutableString.range(of: infoSuffix)
        attributedString.addAttribute(.foregroundColor, value: bodyColor, range: textRange)
        attributedString.addAttribute(.foregroundColor, value: infoColor, range: infoRange)
        attributedText = attributedString
    }

}
