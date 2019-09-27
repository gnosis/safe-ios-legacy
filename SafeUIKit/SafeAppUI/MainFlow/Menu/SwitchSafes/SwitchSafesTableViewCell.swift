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

    enum Animation {
        static let images = (0...46).compactMap { index in
            UIImage(named: String(format: "progress_indicator_%05d", index),
                    in: Bundle(for: SwitchSafesTableViewCell.self),
                    compatibleWith: nil)
        }
        static let duration: TimeInterval = 1.518
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        identiconView.imageView.stopAnimating()
        identiconView.imageView.animationImages = nil
        identiconView.imageView.image = nil
        identiconView.seed = ""
    }

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
        case .pendingCreation, .pendingRecovery:
            identiconView.imageView.animationImages = Animation.images
            identiconView.imageView.animationDuration = Animation.duration
            identiconView.imageView.startAnimating()
            addressLabel.text = walletData.state == .pendingCreation ?
                LocalizedString("deposit_received_creating_safe", comment: "Deposit received. Creating Safe...") :
                LocalizedString("recovering_safe", comment: "Recovering your Safe...")
        case .created:
            identiconView.seed = walletData.address
            addressLabel.address = walletData.address
        }
    }

}
