//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BlockiesSwift
import SafeUIKit

final class SafeTableViewCell: UITableViewCell {

    @IBOutlet weak var safeIconImageView: UIImageView!
    @IBOutlet weak var safeAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var qrCodeButton: UIButton!
    @IBOutlet weak var tappableChevronView: UIView!
    @IBOutlet weak var chevronImageView: UIImageView!

    static let height: CGFloat = 110

    var onShare: (() -> Void)?
    var onShowQRCode: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        safeIconImageView.layer.cornerRadius = safeIconImageView.frame.width / 2
        safeIconImageView.clipsToBounds = true
        tappableChevronView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(showQRCode(_:))))
    }

    func configure(safe: MenuTableViewController.SafeDescription, qrCodeShown: Bool) {
        safeIconImageView.blockiesSeed = safe.address.lowercased()
        safeAddressLabel.address = safe.address
        if qrCodeShown {
            chevronImageView.transform = CGAffineTransform(rotationAngle: .pi)
        }
    }

    @IBAction func share(_ sender: Any) {
        onShare?()
    }

    @IBAction func showQRCode(_ sender: Any) {
        onShowQRCode?()
    }

}
