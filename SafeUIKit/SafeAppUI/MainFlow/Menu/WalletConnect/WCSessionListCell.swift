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
        let imageSize = self.imageSize(screen)
        let placeholder = self.placeholder(size: imageSize, from: wcSessionData)
        if let imageURL = wcSessionData.imageURL {
            dAppImageView.kf.setImage(with: imageURL, placeholder: placeholder)
        } else {
            dAppImageView.image = placeholder
        }
        titleLabel.text = wcSessionData.title
        subtitleLabel.text = wcSessionData.subtitle
        dAppImageViewWidthConstraint.constant = imageSize
        dAppImageViewHeightConstraint.constant = imageSize
    }

    func placeholder(size: CGFloat, from session: WCSessionData) -> UIImage {
        if session.isConnecting { return Asset.dappPlaceholder.image }
        let name: String
        if !session.title.isEmpty {
            name = session.title
        } else if let url = URL(string: session.subtitle), let host = url.host {
            name = host
        } else {
            name = session.subtitle
        }
        let placeholder = PlaceholderCreator().create(size: CGSize(width: size, height: size),
                                                      cornerRadius: 8,
                                                      text: String(name.prefix(1)).uppercased(),
                                                      font: UIFont.systemFont(ofSize: 17, weight: .medium),
                                                      textColor: ColorName.darkSlateBlue.color,
                                                      backgroundColor: ColorName.paleLilac.color)
        return placeholder ?? Asset.dappPlaceholder.image
    }

    func imageSize(_ screen: Screen) -> CGFloat {
        switch screen {
        case .sessions: return 40
        case .review: return 32
        }
    }

}
