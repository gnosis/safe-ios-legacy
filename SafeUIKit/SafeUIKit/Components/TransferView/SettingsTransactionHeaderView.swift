//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class SettingsTransactionHeaderView: BaseCustomView {

    @IBOutlet weak var fromIdenticonView: IdenticonView!
    @IBOutlet weak var fromAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var middleLineView: UIView!

    public var fromAddress: String? {
        didSet {
            update()
        }
    }

    public var titleText: String? {
        didSet {
            update()
        }
    }

    public var detailText: String? {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        safeUIKit_loadFromNib(forClass: SettingsTransactionHeaderView.self)
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = ColorName.darkSlateBlue.color
        middleLineView.backgroundColor = ColorName.paleLilac.color
        detailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = ColorName.darkSlateBlue.color
        fromAddressLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        fromAddressLabel.textColor = ColorName.darkSlateBlue.color
        fromAddressLabel.hasFullAddressTooltip = true
        update()
    }

    public override func update() {
        fromIdenticonView.seed = fromAddress ?? ""
        fromAddressLabel.address = fromAddress
        titleLabel.text = titleText
        detailLabel.text = detailText
    }

    public func setFailed() {
        titleLabel.textColor = ColorName.lightGreyBlue.color
    }

}
