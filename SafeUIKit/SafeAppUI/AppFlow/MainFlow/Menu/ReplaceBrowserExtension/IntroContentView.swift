//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class IntroContentView: NibUIView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!

    @IBOutlet weak var elementsStackView: UIStackView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    struct Style {
        var elementSpacing: CGFloat = 39
        var edgeMargin: CGFloat = 28
        var bottomSpacing: CGFloat = 16
        var headerStyle = ContentHeaderStyle()
        var bodyStyle = ContentBodyStyle()
    }

    struct Strings {
        var header = LocalizedString("replace_extension.intro.header", comment: "Replace browser extension")
        var body = LocalizedString("replace_extension.intro.body", comment: "Intro body text")
    }

    var style = Style()
    var strings = Strings()

    override func setUpConstraints(for contentView: UIView) {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            heightAnchor.constraint(equalTo: contentView.heightAnchor)])
    }

    override func didLoad() {
        topConstraint.constant = style.elementSpacing
        elementsStackView.spacing = style.elementSpacing
        leadingConstraint.constant = style.edgeMargin
        trailingConstraint.constant = style.edgeMargin
        bottomConstraint.constant = style.bottomSpacing
        headerLabel.attributedText = NSAttributedString(string: strings.header, style: style.headerStyle)
        bodyLabel.attributedText = NSAttributedString(string: strings.body, style: style.bodyStyle)
    }

}

class ContentHeaderStyle: AttributedStringStyle {

    override var fontWeight: UIFont.Weight { return .bold }
    override var fontSize: Double { return 20 }
    override var fontColor: UIColor { return ColorName.darkSlateBlue.color }
    override var minimumLineHeight: Double { return 25 }
    override var maximumLineHeight: Double { return 25 }
    override var alignment: NSTextAlignment { return .center }

}

class ContentBodyStyle: AttributedStringStyle {

    override var fontSize: Double { return 16 }
    override var fontColor: UIColor { return ColorName.battleshipGrey.color }
    override var minimumLineHeight: Double { return 25 }
    override var maximumLineHeight: Double { return 25 }
    override var spacingAfterParagraph: Double { return 15 }

}
