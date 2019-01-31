//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

public class FeeCalculationAssetLine: FeeCalculationLine {

    enum Style {
        case plain
        case balance
    }

    typealias InfoItem = (text: String, target: Any?, action: Selector?)

    var style: Style
    var name: String
    var value: String
    var info: InfoItem?

    init(style: Style, name: String, value: String) {
        self.style = style
        self.name = name
        self.value = value
    }

    func setError(_ error: Error?) {}

    override func makeView() -> UIView {
        let textStyle = self.style == .plain ? TextStyle.plain : TextStyle.balance
        let lineStack = UIStackView(arrangedSubviews: [makeName(textStyle: textStyle), makeValue(textStyle: textStyle)])
        lineStack.translatesAutoresizingMaskIntoConstraints = false
        lineStack.heightAnchor.constraint(equalToConstant: CGFloat(lineHeight)).isActive = true
        return lineStack
    }

    func makeName(textStyle: TextStyle) -> UIView {
        let stack = UIStackView()
        let label = UILabel()
        label.attributedText = NSAttributedString(string: name, style: textStyle.name)
        stack.addArrangedSubview(label)
        if let info = self.info {
            stack.addArrangedSubview(makeInfoButton(info: info, textStyle: textStyle))
        }
        return stack
    }

    func makeInfoButton(info: InfoItem, textStyle: TextStyle) -> UIButton {
        let button = UIButton(type: .custom)
        button.setAttributedTitle(NSAttributedString(string: info.text, style: textStyle.info), for: .normal)
        if let action = info.action {
            button.addTarget(info.target, action: action, for: .touchUpInside)
        }
        return button
    }

    func makeValue(textStyle: TextStyle) -> UIView {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: value, style: textStyle.value)
        let huggingPriority = UILayoutPriority(UILayoutPriority.defaultLow.rawValue - 1)
        label.setContentHuggingPriority(huggingPriority, for: .horizontal)
        return label
    }

}
