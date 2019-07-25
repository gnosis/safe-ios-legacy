//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class HorizontalSeparatorView: BaseCustomView {

    var size: CGFloat = 2 {
        didSet {
            update()
        }
    }
    var heightConstraint: NSLayoutConstraint!

    override func commonInit() {
        heightConstraint = heightAnchor.constraint(equalToConstant: 1)
        NSLayoutConstraint.activate(
            [
                heightConstraint
            ])
        update()
    }

    override func update() {
        backgroundColor = ColorName.white.color
        heightConstraint.constant = size
        setNeedsDisplay()
    }

}
