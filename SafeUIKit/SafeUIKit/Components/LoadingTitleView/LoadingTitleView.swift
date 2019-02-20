//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class LoadingTitleView: NibUIView {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var elementsStackView: UIStackView!

    class LabelStyle: AttributedStringStyle {

        override var fontSize: Double { return 16 }
        override var minimumLineHeight: Double { return 21 }
        override var maximumLineHeight: Double { return 21 }
        override var alignment: NSTextAlignment { return .center }
        override var fontColor: UIColor { return ColorName.blueyGrey.color }

    }

    var text = LocalizedString("loading_title_text", comment: "Loading...")
    var titleStyle = LabelStyle()
    var spacing: Double = 5

    public override func didLoad() {
        titleLabel.attributedText = NSAttributedString(string: text, style: titleStyle)
        elementsStackView.spacing = CGFloat(spacing)
    }

}
