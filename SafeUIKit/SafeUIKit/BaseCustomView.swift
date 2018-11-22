//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

open class BaseCustomView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    /// Common initializer called in `init(frame:)` and in `awakeFromNib()`
    /// The base implementation of this method does nothing.
    open func commonInit() {
        // meant for subclassing
    }

    /// Updates view after changing of the model values.
    /// The base implementation of this method does nothing.
    open func update() {
        // meant for subclassing
    }

}
