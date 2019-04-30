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
//        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        safeIconImageView.layer.cornerRadius = safeIconImageView.frame.width / 2
        safeIconImageView.clipsToBounds = true
        safeAddressLabel.textColor = ColorName.lightGreyBlue.color
    }

    func configure(address: String) {
        safeIconImageView.blockiesSeed = address.lowercased()
        safeAddressLabel.address = address
    }

}
