//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class BaseCustomButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    /// Common initializer called in `init(frame:)` and in `awakeFromNib()`
    /// The base implementation of this method does nothing.
    func commonInit() {
        // meant for subclassing
    }

    /// Updates view after changing of the model values.
    /// The base implementation of this method does nothing.
    func update() {
        // meant for subclassing
    }

}
