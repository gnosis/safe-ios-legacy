//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

extension BasicTableViewCell {

    static var tokenDataCellHeight: CGFloat {
        return 62
    }

    func configure(tokenData: TokenData,
                   displayBalance: Bool,
                   displayFullName: Bool,
                   accessoryType: AccessoryType = .disclosureIndicator) {
        accessibilityIdentifier = tokenData.name
        self.accessoryType = accessoryType
        if tokenData.code == "ETH" {
            leftImageView.image = Asset.TokenIcons.eth.image
        } else if let url = tokenData.logoURL {
            leftImageView.kf.setImage(with: url, placeholder: Asset.TokenIcons.defaultToken.image)
        } else {
            leftImageView.image = Asset.TokenIcons.defaultToken.image
        }
        leftTextLabel.text = displayFullName ? "\(tokenData.code) (\(tokenData.name))" : tokenData.code
        rightTextLabel.text = displayBalance ? formattedBalance(tokenData) : nil
    }

    private func formattedBalance(_ tokenData: TokenData) -> String {
        guard let decimal = tokenData.decimalAmount else { return "--" }
        let formatter = TokenFormatter()
        return formatter.string(from: decimal)
    }

}
