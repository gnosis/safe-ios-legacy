//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common
import Kingfisher

public final class TokenBalanceTableViewCell: UITableViewCell {

    @IBOutlet public private(set) weak var tokenImageView: UIImageView!
    @IBOutlet public private(set) weak var tokenCodeLabel: UILabel!
    @IBOutlet public private(set) weak var tokenBalanceLabel: UILabel!
    @IBOutlet public private(set) weak var tokenBalanceCodeLabel: UILabel!

    public static let height: CGFloat = 60

    public func configure(tokenData: TokenData,
                          withBalance: Bool = true,
                          withTokenName: Bool = false,
                          withDisclosure: Bool = true,
                          withTrailingSpace: Bool = false) {
        accessibilityIdentifier = tokenData.name

        if withDisclosure {
            accessoryType = .disclosureIndicator
        } else {
            accessoryType = .none
        }

        if tokenData.code == "ETH" {
            tokenImageView.image = Asset.TokenIcons.eth.image
        } else if let url = tokenData.logoURL {
            tokenImageView.kf.setImage(with: url, placeholder: Asset.TokenIcons.defaultToken.image)
        } else {
            tokenImageView.image = Asset.TokenIcons.defaultToken.image
        }

        tokenCodeLabel.text = withTokenName ? "\(tokenData.code) (\(tokenData.name))" : tokenData.code
        tokenBalanceLabel.text = withBalance ? formattedBalance(tokenData) : nil
        tokenBalanceCodeLabel.text = withBalance ? tokenData.code : nil

        if withTrailingSpace {
            backgroundColor = .clear
        }
    }

    private func formattedBalance(_ tokenData: TokenData) -> String {
        guard let balance = tokenData.balance else { return "--" }
        let formatter = TokenNumberFormatter.ERC20Token(decimals: tokenData.decimals)
        return formatter.string(from: balance)
    }

}
