//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class BorderedButton: BaseCustomButton {

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
        setTitleColor(ColorName.aquaBlue.color, for: .disabled)
        setTitleColor(ColorName.aquaBlue.color, for: [.disabled, .selected])
        setTitleColor(ColorName.aquaBlue.color, for: [.disabled, .highlighted])
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
        setTitleColor(isEnabled ? .white : ColorName.aquaBlue.color, for: .normal)
    }

    override func update() {
        if isEnabled && isHighlighted {
            backgroundColor = ColorName.darkAzure.color
            alpha = 1.0
        } else if isEnabled {
            backgroundColor = ColorName.aquaBlue.color
            alpha = 1.0
        } else {
            backgroundColor = .white
            alpha = 0.5
        }
    }

}
