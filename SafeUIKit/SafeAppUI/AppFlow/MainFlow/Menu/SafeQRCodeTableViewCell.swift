//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

final class SafeQRCodeTableViewCell: UITableViewCell {

    @IBOutlet weak var qrCodeView: QRCodeView!
    @IBOutlet weak var addressLabel: UILabel!

    static let height: CGFloat = 250

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func configure(code: MenuTableViewController.SafeQRCode) {
        qrCodeView.value = code.address
        qrCodeView.padding = 12
        qrCodeView.layer.borderWidth = 1
        qrCodeView.layer.borderColor = UIColor.black.cgColor
        qrCodeView.layer.cornerRadius = 6
        addressLabel.setEthereumAddress(code.address)
    }

}
