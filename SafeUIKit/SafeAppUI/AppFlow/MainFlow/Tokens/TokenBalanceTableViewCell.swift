//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Kingfisher

class TokenBalanceTableViewCell: UITableViewCell {

    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var tokenCodeLabel: UILabel!
    @IBOutlet weak var tokenBalanceLabel: UILabel!

    static let height: CGFloat = 44

    func configure(tokenData: TokenData,
                   withBalance: Bool = true,
                   withTokenName: Bool = false,
                   withDisclosure: Bool = true) {
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
    }

    private func formattedBalance(_ tokenData: TokenData) -> String {
        guard let balance = tokenData.balance else { return "--" }
        let formatter = TokenNumberFormatter.ERC20Token(code: tokenData.code, decimals: tokenData.decimals)
        return formatter.string(from: balance)
    }

}
