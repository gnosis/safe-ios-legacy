//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class SafeTableViewCell: UITableViewCell {

    @IBOutlet weak var safeIconImageView: UIImageView!
    @IBOutlet weak var safeAddressLabel: UILabel!
    @IBOutlet weak var safeNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        safeIconImageView.layer.cornerRadius = safeIconImageView.frame.width / 2
        safeIconImageView.clipsToBounds = true
        backgroundView = UIView()
        backgroundView?.backgroundColor = ColorName.paleGreyThree.color
    }

    func configure(safe: SettingsTableViewController.SafeDescription) {
        safeIconImageView.image = safe.image
        safeNameLabel.text = safe.name
        safeAddressLabel.text = safe.address
    }

}
