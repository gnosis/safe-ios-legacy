//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class HeaderImageTextView: BaseCustomView {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!

    override func commonInit() {
        safeUIKit_loadFromNib(forClass: HeaderImageTextView.self)

        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.heightAnchor.constraint(equalTo: contentStackView.heightAnchor).isActive = true
        wrapAroundDynamicHeightView(wrapperView, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

        titleLabel.textColor = ColorName.darkBlue.color
        textLabel.textColor = ColorName.darkGrey.color
    }

    func setTitle(_ title: String?, showError: Bool = false) {
        guard let title = title else {
            titleLabel.isHidden = true
            return
        }
        let titleText = NSMutableAttributedString()
        if showError {
            let attachment = NSTextAttachment(image: Asset.errorIcon.image,
                                              bounds: CGRect(x: 0, y: -2, width: 16, height: 16))
            titleText.append(attachment)
            titleText.append("  ")
        }
        titleText.append(NSAttributedString(string: title))
        titleLabel.attributedText = titleText
    }

}
