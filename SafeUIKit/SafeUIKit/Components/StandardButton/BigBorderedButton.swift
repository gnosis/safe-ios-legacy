//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final public class StandardButton: BaseCustomButton {

    public enum Style {
        case plain
        case bordered
        case filled
    }

    public var style: Style = .bordered {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        titleLabel?.font = UIFont.systemFont(ofSize: 17)
    }

    public override func update() {
        setTitleColor(.white, for: .normal)
        setTitleColor(ColorName.darkSlateBlue.color, for: .highlighted)
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        layer.borderWidth = 0
        layer.cornerRadius = 10
        layer.shadowOpacity = 0
        backgroundColor = .clear
        switch style {
        case .bordered:
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 1
        case .plain:
            setTitleColor(ColorName.aquaBlue.color, for: .normal)
            layer.cornerRadius = 0
        case .filled:
            backgroundColor = ColorName.aquaBlue.color
            layer.shadowColor = ColorName.lightBlueGrey58.color.cgColor
            layer.shadowOpacity = 0.58
            layer.shadowOffset = CGSize(width: 1, height: 2)
        }
    }

}
