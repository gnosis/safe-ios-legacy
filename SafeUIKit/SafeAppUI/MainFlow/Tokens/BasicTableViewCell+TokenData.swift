//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

extension BasicTableViewCell {

    func configure(tokenData: TokenData,
                   displayBalance: Bool,
                   displayFullName: Bool,
                   roundUp: Bool = false,
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
        if displayFullName {
            splitLeftTextLabel(title: tokenData.code, subtitle: tokenData.name)
        } else {
            leftTextLabel.text = tokenData.code
        }
        rightTextLabel.text = displayBalance ? formattedBalance(tokenData, roundUp: roundUp) : nil
    }

    private func formattedBalance(_ tokenData: TokenData, roundUp: Bool) -> String {
        guard let decimal = tokenData.decimalAmount else { return "--" }
        let formatter = TokenFormatter()
        formatter.roundingBehavior = roundUp ? .roundUp : .cutoff
        return formatter.localizedString(from: decimal)
    }

}
