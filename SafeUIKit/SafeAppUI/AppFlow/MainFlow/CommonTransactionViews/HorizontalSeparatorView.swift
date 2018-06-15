//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class HorizontalSeparatorView: DesignableView {

    @IBInspectable
    var size: CGFloat = 1 {
        didSet {
            setNeedsUpdate()
        }
    }
    var heightConstraint: NSLayoutConstraint!

    override func commonInit() {
        heightConstraint = heightAnchor.constraint(equalToConstant: 1)
        NSLayoutConstraint.activate(
            [
                heightConstraint
            ])
        didLoad()
    }

    override func update() {
        backgroundColor = ColorName.paleGreyFour.color
        heightConstraint.constant = size
        setNeedsDisplay()
    }

}
