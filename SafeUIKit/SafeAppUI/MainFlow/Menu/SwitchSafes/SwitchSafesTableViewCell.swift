//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

class SwitchSafesTableViewCell: UITableViewCell {

    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: EthereumAddressLabel!
    @IBOutlet weak var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = ColorName.darkBlue.color
        addressLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        addressLabel.textColor = ColorName.mediumGrey.color
        separatorView.backgroundColor = ColorName.white.color
    }

    func configure(walletData: WalletData) {
        nameLabel.text = walletData.name
        switch walletData.state {
        case .pending:
            identiconView.imageView.image = Asset.CreateSafe.cryptoWithoutHassle.image
            addressLabel.text = LocalizedString("deposit_received_creating_safe",
                                                comment: "Deposit received. Creating Safe...")
        case .created:
            identiconView.seed = walletData.address
            addressLabel.address = walletData.address
        }
    }

}
