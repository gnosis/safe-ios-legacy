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

    private var backgroundColorForState = [UIControl.State.RawValue: UIColor]() {
        didSet {
            updateBackground()
        }
    }

    public override func commonInit() {
        titleLabel?.font = UIFont.systemFont(ofSize: 17)
        update()
    }

    public override func update() {
        setTitleColor(ColorName.darkBlue.color, for: .normal)
        setTitleColor(ColorName.darkBlue50.color, for: .highlighted)
        setTitleColor(ColorName.darkBlue50.color, for: .disabled)

        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        layer.borderWidth = 0
        layer.cornerRadius = 10
        layer.shadowOpacity = 0
        backgroundColor = ColorName.transparent.color
        backgroundColorForState = [UIControl.State.normal.rawValue: ColorName.transparent.color]
        switch style {
        case .bordered:
            layer.borderColor = ColorName.darkBlue.color.cgColor
            layer.borderWidth = 2
        case .plain:
            setTitleColor(ColorName.hold.color, for: .normal)
            setTitleColor(ColorName.holdDark.color, for: .highlighted)
            layer.cornerRadius = 0
        case .filled:
            setTitleColor(ColorName.snowwhite.color, for: .normal)
            setTitleColor(ColorName.white.color, for: .highlighted)
            setTitleColor(ColorName.white.color, for: .disabled)
            backgroundColor = ColorName.hold.color
            backgroundColorForState = [UIControl.State.normal.rawValue: ColorName.hold.color,
                                       UIControl.State.highlighted.rawValue: ColorName.holdDark.color,
                                       UIControl.State.disabled.rawValue: ColorName.hold50.color]
            layer.shadowColor = ColorName.cardShadow.color.cgColor
            layer.shadowOpacity = 0.59
            layer.shadowOffset = CGSize(width: 1, height: 2)
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            updateBackground()
        }
    }

    public override var isEnabled: Bool {
        didSet {
            updateBackground()
        }
    }

    func updateBackground() {
        if let color = backgroundColorForState[state.rawValue], backgroundColor != color {
            backgroundColor = color
        }
    }

}
