//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

public class IntroContentView: NibUIView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var feeCalculationView: FeeCalculationView!

    @IBOutlet weak var elementsStackView: UIStackView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!

    struct Style {
        var elementSpacing: CGFloat = 25
        var edgeMargin: CGFloat = 16
        var headerStyle = ContentHeaderStyle()
        var bodyStyle = ContentBodyStyle()
    }

    struct Content {
        var header = LocalizedString("ios_replace_browser_extension", comment: "Replace browser extension")
            .replacingOccurrences(of: "\n", with: " ")
        var body = LocalizedString("once_process_is_complete", comment: "Intro body text")
        var icon = Asset.ReplaceBrowserExtension.introIcon.image
    }

    var style = Style()
    var content = Content()

    public override func setUpConstraints(for contentView: UIView) {
        wrapAroundDynamicHeightView(contentView)
    }

    public override func didLoad() {
        topConstraint.constant = style.elementSpacing
        elementsStackView.spacing = style.elementSpacing
        leadingConstraint.constant = style.edgeMargin
        trailingConstraint.constant = style.edgeMargin
        iconImageView.image = content.icon
        headerLabel.attributedText = NSAttributedString(string: content.header, style: style.headerStyle)
        bodyLabel.attributedText = NSAttributedString(string: content.body, style: style.bodyStyle)
    }

}

class ContentHeaderStyle: AttributedStringStyle {

    override var fontWeight: UIFont.Weight { return .semibold }
    override var fontSize: Double { return 17 }
    override var fontColor: UIColor { return ColorName.darkBlue.color }
    override var minimumLineHeight: Double { return 22 }
    override var maximumLineHeight: Double { return 22 }
    override var alignment: NSTextAlignment { return .center }

}

class ContentBodyStyle: AttributedStringStyle {

    override var fontSize: Double { return 17 }
    override var fontColor: UIColor { return ColorName.darkGrey.color }
    override var minimumLineHeight: Double { return 22 }
    override var maximumLineHeight: Double { return 22 }

}
