//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol InfoLabelDelegate: class {
    func didTap()
}

public class InfoLabel: UILabel {

    public weak var delegate: InfoLabelDelegate?

    public var infoSuffix = "[?]"

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        font = UIFont.systemFont(ofSize: 17)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapRecognizer)
        isUserInteractionEnabled = true
    }

    @objc private func didTap() {
        delegate?.didTap()
    }

    public func setInfoText(_ text: String) {
        let attributedString = NSMutableAttributedString(string: "\(text)\u{00A0}\(infoSuffix)")
        let textRange = attributedString.mutableString.range(of: text)
        let infoRange = attributedString.mutableString.range(of: infoSuffix)
        attributedString.addAttribute(.foregroundColor, value: ColorName.battleshipGrey.color, range: textRange)
        attributedString.addAttribute(.foregroundColor, value: ColorName.darkSkyBlue.color, range: infoRange)
        attributedText = attributedString
    }

}
