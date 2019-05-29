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

    /// Used if table view section index should be displayed
    public var withTrailingSpace: Bool = false {
        didSet {
            backgroundColor = withTrailingSpace ? .clear : .white
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
        leftTextLabel.textColor = ColorName.darkSlateBlue.color
        leftTextLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        rightTextLabel.textColor = ColorName.darkSlateBlue.color
        rightTextLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        separatorView.backgroundColor = ColorName.paleGrey.color
        let selectedView = UIView()
        selectedView.backgroundColor = ColorName.paleGreyThree.color
        selectedBackgroundView = selectedView
    }

}
