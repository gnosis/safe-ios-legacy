//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Kingfisher

final class WCSessionListCell: UITableViewCell {

    @IBOutlet weak var dAppImageView: UIImageView!
    @IBOutlet weak var dAppImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dAppImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = ColorName.darkSlateBlue.color
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = ColorName.lightGreyBlue.color
        separatorView.backgroundColor = ColorName.paleGrey.color
    }

    enum Screen {
        case sessions
        case review
    }

    func configure(wcSessionData: WCSessionData, screen: Screen) {
        if let imageURL = wcSessionData.imageURL {
            dAppImageView.kf.setImage(with: imageURL, placeholder: Asset.TokenIcons.defaultToken.image)
        } else {
            dAppImageView.image = Asset.dappPlaceholder.image
        }
        titleLabel.text = wcSessionData.title
        subtitleLabel.text = wcSessionData.subtitle
        switch screen {
        case .sessions:
            dAppImageViewWidthConstraint.constant = 40
            dAppImageViewHeightConstraint.constant = 40
        case .review:
            dAppImageViewWidthConstraint.constant = 32
            dAppImageViewHeightConstraint.constant = 32
        }
    }

}
