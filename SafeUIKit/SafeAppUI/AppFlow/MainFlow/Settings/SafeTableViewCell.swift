//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class SafeTableViewCell: UITableViewCell {

    @IBOutlet weak var safeIconImageView: UIImageView!
    @IBOutlet weak var safeAddressLabel: UILabel!
    @IBOutlet weak var safeNameLabel: UILabel!

    func configure(safe: SafeDescription) {
        safeIconImageView.image = safe.image
        safeIconImageView.layer.cornerRadius = safeIconImageView.frame.width / 2
        safeIconImageView.clipsToBounds = true

        safeNameLabel.text = safe.name
        safeAddressLabel.text = safe.address

        backgroundView = UIView()
        backgroundView?.backgroundColor = ColorName.paleGreyThree.color
    }

}
