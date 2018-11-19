//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Kingfisher

public class TransactionHeaderView: UIView {

    @IBOutlet weak private(set) var assetImageView: UIImageView!
    @IBOutlet weak private(set) var assetCodeLabel: UILabel!
    @IBOutlet weak private(set) var assetInfoLabel: UILabel!

    public var assetImage: UIImage? {
        didSet {
            assetImageView.image = assetImage
        }
    }

    public var assetImageURL: URL? {
        didSet {
            assetImageView.kf.setImage(with: assetImageURL)
        }
    }

    public var assetCode: String? {
        didSet {
            assetCodeLabel.text = assetCode
        }
    }

    public var assetInfo: String? {
        didSet {
            assetInfoLabel.text = assetInfo
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        safeUIKit_loadFromNib(forClass: TransactionHeaderView.self)
        assetImageView.image = nil
        assetCodeLabel.text = nil
        assetInfoLabel.text = nil
    }

}
