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
        setTitleColor(.white, for: .normal)
        setTitleColor(ColorName.darkSlateBlue.color, for: .highlighted)
        setTitleColor(.gray, for: .disabled)

        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        layer.borderWidth = 0
        layer.cornerRadius = 10
        layer.shadowOpacity = 0
        backgroundColor = .clear
        backgroundColorForState = [UIControl.State.normal.rawValue: .clear]
        switch style {
        case .bordered:
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 1
        case .plain:
            setTitleColor(ColorName.darkSkyBlue.color, for: .normal)
            layer.cornerRadius = 0
        case .filled:
            backgroundColor = ColorName.darkSkyBlue.color
            backgroundColorForState = [UIControl.State.normal.rawValue: ColorName.darkSkyBlue.color,
                                       UIControl.State.highlighted.rawValue: ColorName.dodgerBlue.color,
                                       UIControl.State.disabled.rawValue: ColorName.paleGrey.color]
            setTitleColor(.white, for: .highlighted)
            layer.shadowColor = ColorName.lightBlueGrey58.color.cgColor
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
