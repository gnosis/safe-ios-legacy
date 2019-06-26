//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import SafeUIKit

extension BasicTableViewCell {

    func configure(wcSessionData: WCSessionData) {
        accessoryType = .none
        leftImageView.image = wcSessionData.image
        splitLeftTextLabel(title: wcSessionData.title, subtitle: wcSessionData.subtitle)
    }

}
