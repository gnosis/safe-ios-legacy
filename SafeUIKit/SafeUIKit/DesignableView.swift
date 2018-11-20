//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

open class DesignableView: UIView {

    private var isLoaded = false

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

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsUpdate()
    }

    /// Common initializer called in `init(frame:)` and in `awakeFromNib()`
    /// At some point in this method you must call `didLoad()` in order to enable view updates.
    /// The base implementation of this method does nothing.
    open func commonInit() {
        // meant for subclassing
    }

    /// Updates view after changing of the model values, and in `prepareForInterfaceBuilder()`.
    /// Don't call this method directly. Instead, please call `setNeedsUpdate()`.
    /// Update will not be called if `didLoad()` hasn't been called before.
    /// The base implementation of this method does nothing.
    open func update() {
        // meant for subclassing
    }

    /// Call this method when your view model changes and view has to be updated.
    open func setNeedsUpdate() {
        guard isLoaded else { return }
        update()
    }

    /// Indicates that view initialization complete and updates can be performed.
    open func didLoad() {
        isLoaded = true
        setNeedsUpdate()
    }

}
