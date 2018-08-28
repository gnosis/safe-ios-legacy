//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class TokenBalanceTableViewCell: UITableViewCell {

    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var tokenCodeLabel: UILabel!
    @IBOutlet weak var tokenBalanceLabel: UILabel!

    static let height: CGFloat = 60

    func configure(tokenData: TokenData) {
        let bundle = Bundle(for: TokenBalanceTableViewCell.self)
        if let image = UIImage(named: tokenData.code, in: bundle, compatibleWith: nil) {
            tokenImageView.image = image
        } else {
            tokenImageView.image = Asset.TokenIcons.defaultToken.image
        }
        tokenCodeLabel.text = tokenData.code
        tokenBalanceLabel.text = formattedBalance(tokenData)
    }

    private func formattedBalance(_ tokenData: TokenData) -> String {
        guard let balance = tokenData.balance else { return "--" }
        let formatter = TokenNumberFormatter.ERC20Token(decimals: tokenData.decimals)
        return formatter.string(from: balance)
    }

}
