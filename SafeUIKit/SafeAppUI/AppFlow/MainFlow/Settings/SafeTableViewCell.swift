//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class SafeTableViewCell: UITableViewCell {

    @IBOutlet weak var safeIconImageView: UIImageView!
    @IBOutlet weak var safeAddressLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var qrCodeButton: UIButton!
    @IBOutlet weak var tappableChevronView: UIView!

    var onShare: (() -> Void)?
    var onShowQRCode: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        safeIconImageView.layer.cornerRadius = safeIconImageView.frame.width / 2
        safeIconImageView.clipsToBounds = true
        tappableChevronView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(showQRCode(_:))))
    }

    func configure(safe: MenuTableViewController.SafeDescription) {
        safeIconImageView.image = safe.image
        safeAddressLabel.text = safe.address
    }

    @IBAction func share(_ sender: Any) {
        onShare?()
    }

    @IBAction func showQRCode(_ sender: Any) {
        onShowQRCode?()
    }

}
