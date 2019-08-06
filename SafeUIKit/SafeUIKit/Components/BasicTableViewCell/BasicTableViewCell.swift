//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

open class BasicTableViewCell: UITableViewCell {

    @IBOutlet public private(set) weak var leftImageView: UIImageView!
    @IBOutlet public private(set) weak var leftTextLabel: UILabel!
    @IBOutlet public private(set) weak var rightTextLabel: UILabel!
    @IBOutlet public private(set) weak var separatorView: UIView!
    @IBOutlet public private(set) weak var rightTrailingConstraint: NSLayoutConstraint!

    public static let titleOnlyHeight: CGFloat = 62
    public static let titleAndSubtitleHeight: CGFloat = 70

    /// Used if table view section index should be displayed
    public var withTrailingSpace: Bool = false {
        didSet {
            backgroundColor = withTrailingSpace ? ColorName.transparent.color : ColorName.snowwhite.color
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        leftTextLabel?.text = nil
        leftTextLabel?.attributedText = nil
        rightTextLabel?.text = nil
        rightTextLabel?.attributedText = nil
    }

    open func commonInit() {
        leftTextLabel.text = nil
        leftTextLabel.textColor = ColorName.darkBlue.color
        leftTextLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        rightTextLabel.text = nil
        rightTextLabel.textColor = ColorName.darkBlue.color
        rightTextLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        separatorView.backgroundColor = ColorName.white.color
        let selectedView = UIView()
        selectedView.backgroundColor = ColorName.whitesmokeTwo.color
        selectedBackgroundView = selectedView
    }

    open func splitLeftTextLabel(title: String, subtitle: String) {
        let fullText = NSMutableAttributedString()
        let titleText = NSAttributedString(string: title + "\n", style: TitleStyle())
        let subtitleText = NSAttributedString(string: subtitle, style: SubtitleStyle())
        fullText.append(titleText)
        fullText.append(subtitleText)
        leftTextLabel.numberOfLines = 0
        leftTextLabel.attributedText = fullText
    }

}

fileprivate class TitleStyle: AttributedStringStyle {

    override var fontSize: Double { return 16 }
    override var fontWeight: UIFont.Weight { return .medium }
    override var fontColor: UIColor { return ColorName.darkBlue.color }
    override var spacingAfterParagraph: Double { return 4 }

}

fileprivate class SubtitleStyle: AttributedStringStyle {

    override var fontSize: Double { return 13 }
    override var fontWeight: UIFont.Weight { return .medium }
    override var fontColor: UIColor { return ColorName.mediumGrey.color }

}
