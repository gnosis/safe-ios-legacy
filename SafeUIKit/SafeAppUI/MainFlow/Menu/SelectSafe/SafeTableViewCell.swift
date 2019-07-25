//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BlockiesSwift
import SafeUIKit

final class SafeTableViewCell: UITableViewCell {

    @IBOutlet weak var safeIconImageView: UIImageView!
    @IBOutlet weak var safeAddressLabel: EthereumAddressLabel!

    static let height: CGFloat = 70

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        safeIconImageView.layer.cornerRadius = safeIconImageView.frame.width / 2
        safeIconImageView.clipsToBounds = true
        safeAddressLabel.textColor = ColorName.mediumGrey.color
    }

    func configure(address: String) {
        safeIconImageView.blockiesSeed = address.lowercased()
        safeAddressLabel.address = address
    }

}
