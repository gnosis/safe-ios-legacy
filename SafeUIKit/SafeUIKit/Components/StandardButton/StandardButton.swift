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
        setTitleColor(ColorName.transparent.color, for: .normal)
        setTitleColor(ColorName.darkBlue.color, for: .highlighted)
        setTitleColor(ColorName.mediumGrey.color, for: .disabled)

        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        layer.borderWidth = 0
        layer.cornerRadius = 10
        layer.shadowOpacity = 0
        backgroundColor = ColorName.transparent.color
        backgroundColorForState = [UIControl.State.normal.rawValue: ColorName.transparent.color]
        switch style {
        case .bordered:
            layer.borderColor = ColorName.snowwhite.color.cgColor
            layer.borderWidth = 2
        case .plain:
            setTitleColor(ColorName.hold.color, for: .normal)
            layer.cornerRadius = 0
        case .filled:
            backgroundColor = ColorName.hold.color
            backgroundColorForState = [UIControl.State.normal.rawValue: ColorName.hold.color,
                                       UIControl.State.highlighted.rawValue: ColorName.holdTwo.color,
                                       UIControl.State.disabled.rawValue:
                                        ColorName.hold.color.withAlphaComponent(0.5)]
            setTitleColor(ColorName.snowwhite.color, for: .highlighted)
            setTitleColor(ColorName.snowwhite.color, for: .disabled)
            layer.shadowColor = ColorName.cardShadow.color.cgColor
            layer.shadowOpacity = 0.58
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
