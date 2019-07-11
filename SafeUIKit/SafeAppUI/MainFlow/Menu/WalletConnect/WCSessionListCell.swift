//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Kingfisher

final class WCSessionListCell: UITableViewCell {

    @IBOutlet weak var dAppImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = ColorName.darkSlateBlue.color
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = ColorName.lightGreyBlue.color
    }

    func configure(wcSessionData: WCSessionData) {
        // TODO: what is a proper placeholder image?
        if let imageURL = wcSessionData.imageURL {
            dAppImageView.kf.setImage(with: imageURL, placeholder: Asset.TokenIcons.defaultToken.image)
        } else {
            dAppImageView.image = Asset.TokenIcons.defaultToken.image
        }
        titleLabel.text = wcSessionData.title
        subtitleLabel.text = wcSessionData.subtitle
    }

}
