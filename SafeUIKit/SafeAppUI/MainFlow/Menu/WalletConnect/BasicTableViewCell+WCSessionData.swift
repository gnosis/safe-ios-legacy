//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import SafeUIKit
import MultisigWalletApplication
import Kingfisher

extension BasicTableViewCell {

    func configure(wcSessionData: WCSessionData) {
        accessoryType = .none
        // TODO: what is a proper placeholder image?
        if let imageURL = wcSessionData.imageURL {
            leftImageView.kf.setImage(with: imageURL, placeholder: Asset.TokenIcons.defaultToken.image)
        } else {
            leftImageView.image = Asset.TokenIcons.defaultToken.image
        }
        splitLeftTextLabel(title: wcSessionData.title, subtitle: wcSessionData.subtitle)
        rightTextLabel.text = nil
    }

}
