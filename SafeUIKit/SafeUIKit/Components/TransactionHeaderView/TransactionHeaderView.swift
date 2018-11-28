//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Kingfisher

public class TransactionHeaderView: BaseCustomView {

    @IBOutlet weak private(set) var assetImageView: UIImageView!
    @IBOutlet weak private(set) var assetCodeLabel: UILabel!
    @IBOutlet weak private(set) var assetInfoLabel: UILabel!

    public var usesEthImageWhenImageURLIsNil = false {
        didSet {
            update()
        }
    }

    public var assetImage: UIImage? {
        didSet {
            update()
        }
    }

    public var assetImageURL: URL? {
        didSet {
            update()
        }
    }

    public var assetCode: String? {
        didSet {
            update()
        }
    }

    public var assetInfo: String? {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        safeUIKit_loadFromNib(forClass: TransactionHeaderView.self)
        subviews.first?.backgroundColor = ColorName.paleGreyThree.color
        update()
    }

    public override func update() {
        if let url = assetImageURL {
            assetImageView.kf.setImage(with: url)
        } else {
            assetImageView.image = usesEthImageWhenImageURLIsNil ?
                Asset.TokenIcons.eth.image : assetImage
        }
        assetCodeLabel.text = assetCode
        assetInfoLabel.text = assetInfo
    }

}
