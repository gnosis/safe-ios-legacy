//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit

class MainBannerView: BaseCustomView {

    @IBOutlet weak var banner: UIView!
    @IBOutlet weak var errorIcon: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    var height: CGFloat {
        get {
            return heightConstraint?.constant ?? 0
        }
        set {
            heightConstraint?.constant = newValue
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    var text: String? {
        get {
            return textLabel?.text
        }
        set {
            textLabel?.text = newValue
        }
    }

    var onTap: (() -> Void)?

    override func commonInit() {
        textLabel.textColor = ColorName.darkBlue.color
        textLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        banner.layer.cornerRadius = 10
        banner.layer.shadowOffset = CGSize(width: 1, height: 2)
        banner.layer.shadowRadius = 10
        banner.layer.shadowColor = ColorName.cardShadow.color.cgColor
        banner.layer.shadowOpacity = 0.59

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBanner(_:)))
        banner.addGestureRecognizer(tapRecognizer)
    }

    @IBAction func didTapBanner(_ sender: Any) {
        onTap?()
    }

}
