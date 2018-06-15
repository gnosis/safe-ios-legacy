//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class BorderedButton: DesignableButton {

    private var stateObservation: NSKeyValueObservation!
    private var background: UIView!

    override var isEnabled: Bool {
        didSet {
            setNeedsUpdate()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            setNeedsUpdate()
        }
    }

    override func commonInit() {
        setTitleColor(.white, for: .normal)
        setTitleColor(ColorName.azure.color, for: .disabled)
        setTitleColor(ColorName.azure.color, for: [.disabled, .selected])
        setTitleColor(ColorName.azure.color, for: [.disabled, .highlighted])
        let label = titleLabel!
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 0)
        didLoad()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        // otherwise IB doesn't update title color with correct value for the disabled state.
        setTitleColor(isEnabled ? .white : ColorName.azure.color, for: .normal)
    }

    override func update() {
        if isEnabled && isHighlighted {
            backgroundColor = ColorName.darkAzure.color
            alpha = 1.0
        } else if isEnabled {
            backgroundColor = ColorName.azure.color
            alpha = 1.0
        } else {
            backgroundColor = .white
            alpha = 0.5
        }
    }

}
