//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

public class IntroContentView: NibUIView {

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
        var headerStyle = HeaderStyle()
        var bodyStyle = DescriptionStyle()
    }

    struct Content {
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
        bodyLabel.attributedText = NSAttributedString(string: content.body, style: style.bodyStyle)
    }

}
