//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public extension UILabel {

    func setEthereumAddress(_ address: String) {
        guard address.count > 8 else { return }
        let attrStr = NSMutableAttributedString(string: address)
        attrStr.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: ColorName.blueyGrey.color,
            range: NSRange(location: 4, length: attrStr.length - 8))
        attributedText = attrStr
    }

}
