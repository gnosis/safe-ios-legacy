//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class SKPairSuccessView: BaseCustomView {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!

    class TextStyle: AttributedStringStyle {

        override var fontSize: Double { return 17 }
        override var fontColor: UIColor { return ColorName.darkGrey.color }
        override var alignment: NSTextAlignment { return .center }

    }

    class TitleStyle: TextStyle {

        override var fontWeight: UIFont.Weight { return .semibold }
        override var fontColor: UIColor { return ColorName.darkBlue.color }

    }

    enum Strings {
        static let title = LocalizedString("keycard_paired", comment: "Paired")
        static let text = LocalizedString("after_finishing_setup", comment: "Description")
    }

    override func commonInit() {
        safeUIKit_loadFromNib(forClass: SKPairSuccessView.self)

        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.heightAnchor.constraint(equalTo: contentStackView.heightAnchor).isActive = true
        wrapAroundDynamicHeightView(wrapperView, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

        titleLabel.attributedText = NSAttributedString(string: Strings.title, style: TitleStyle())
        textLabel.attributedText = NSAttributedString(string: Strings.text, style: TextStyle())
    }

}
