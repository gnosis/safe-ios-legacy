//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class AddressDetailView: BaseCustomView {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var addressStackView: UIStackView!
    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var addressLabel: FullEthereumAddressLabel!
    @IBOutlet weak var shareButton: UIButton!

    @IBOutlet weak var qrCodeView: QRCodeView!
    @IBOutlet weak var footnoteLabel: UILabel!

    var address: String? {
        didSet {
            if let address = address {
                identiconView.seed = address
            }
            addressLabel.address = address
            qrCodeView.value = address
        }
    }

    override func commonInit() {
        safeUIKit_loadFromNib(forClass: AddressDetailView.self)

        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.heightAnchor.constraint(equalTo: contentStackView.heightAnchor).isActive = true
        wrapAroundDynamicHeightView(wrapperView, insets: UIEdgeInsets(top: 23, left: 0, bottom: 0, right: 0))

        addressLabel.hasCopyAddressTooltip = true
        footnoteLabel.textColor = ColorName.tomato.color

        qrCodeView.padding = 12
        qrCodeView.backgroundColor = ColorName.snowwhite.color
        qrCodeView.layer.borderWidth = 1
        qrCodeView.layer.borderColor = ColorName.black.color.cgColor
        qrCodeView.layer.cornerRadius = 9

        addressLabel.numberOfLines = 2
        addressLabel.lineBreakMode = .byClipping

        shareButton.setImage(Asset.shareIcon.image, for: .normal)
    }

}
