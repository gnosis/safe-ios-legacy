//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class TokenBalanceTableViewCell: UITableViewCell {

    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var tokenNameLabel: UILabel!
    @IBOutlet weak var tokenBalanceLabel: UILabel!
    @IBOutlet weak var fiatBalanceLabel: UILabel!

    func configure(balance: TokenBalance) {
        let bundle = Bundle(for: TokenBalanceTableViewCell.self)
        if let image = UIImage(named: balance.token, in: bundle, compatibleWith: nil) {
            tokenImageView.image = image
        } else {
            tokenImageView.image = Asset.TokenIcons.defaultToken.image
        }
        tokenNameLabel.text = balance.token
        tokenBalanceLabel.text = balance.balance
        fiatBalanceLabel.text = balance.fiatBalance
    }

}
