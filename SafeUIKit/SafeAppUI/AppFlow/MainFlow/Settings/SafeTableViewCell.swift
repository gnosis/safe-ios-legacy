//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class SafeTableViewCell: UITableViewCell {

    @IBOutlet weak var safeIconImageView: UIImageView!
    @IBOutlet weak var safeAddressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        safeIconImageView.layer.cornerRadius = safeIconImageView.frame.width / 2
        safeIconImageView.clipsToBounds = true
    }

    func configure(safe: MenuTableViewController.SafeDescription) {
        safeIconImageView.image = safe.image
        safeAddressLabel.text = safe.address
    }

}
