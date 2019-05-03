//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit

public class FeeCalculationAssetLine: FeeCalculationLine {

    enum Style {
        case plain
        case balance
    }

    struct AssetInfo: Equatable {

        var name: String
        var button: ButtonItem?
        var value: String?
        /// If set, then valueButton is shown instead of value
        var valueButton: ButtonItem?
        var error: Error?

        static let empty = AssetInfo(name: "", button: nil, value: "", valueButton: nil, error: nil)

        static func == (lhs: FeeCalculationAssetLine.AssetInfo, rhs: FeeCalculationAssetLine.AssetInfo) -> Bool {
            return lhs.name == rhs.name &&
                lhs.button == rhs.button &&
                lhs.value == rhs.value &&
                String(describing: lhs.error) == String(describing: rhs.error)
        }

    }

    struct ButtonItem: Equatable {

        var text: String
        var target: AnyClass?
        var action: Selector?
        var icon: UIImage?

        static func == (lhs: FeeCalculationAssetLine.ButtonItem, rhs: FeeCalculationAssetLine.ButtonItem) -> Bool {
            return lhs.text == rhs.text &&
                lhs.target === rhs.target &&
                String(describing: lhs.action) == String(describing: rhs.action)
        }

    }

    var style: Style = .plain
    var asset: AssetInfo = .empty
    private var tooltip: String?

    public private(set) var tooltipSource: TooltipSource!

    override func makeView() -> UIView {
        let textStyle = self.style == .plain ? TextStyle.plain : TextStyle.balance
        let lineStack = UIStackView(arrangedSubviews: [makeName(textStyle: textStyle),
                                                       makeValue(textStyle: textStyle)])
        lineStack.translatesAutoresizingMaskIntoConstraints = false
        return lineStack
    }

    func makeName(textStyle: TextStyle) -> UIView {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: asset.name, style: textStyle.name)
        // Note, setting compression resistance priority here breaks the stackview alignment when tooltip
        // is shown from the 'value' label. That's why it was removed, and the name is not shrinking
        // horizontally.
        guard let buttonData = asset.button else {
            return label
        }
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        let stack = UIStackView(arrangedSubviews: [label, makeInfoButton(button: buttonData, textStyle: textStyle)])
        stack.spacing = 5
        return stack
    }

    func makeInfoButton(button buttonData: ButtonItem, textStyle: TextStyle) -> UIButton {
        let button = UIButton(type: .custom)
        button.setAttributedTitle(NSAttributedString(string: buttonData.text, style: textStyle.info), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        if let action = buttonData.action {
            button.addTarget(buttonData.target, action: action, for: .touchUpInside)
        }
        button.contentHorizontalAlignment = .left
        return button
    }

    func makeValue(textStyle: TextStyle) -> UIView {
        if let valueButton = asset.valueButton {
            let button = UIButton(type: .custom)
            button.setAttributedTitle(NSAttributedString(string: valueButton.text, style: textStyle.valueButton),
                                      for: .normal)
            if let action = valueButton.action {
                button.addTarget(valueButton.target, action: action, for: .touchUpInside)
            }
            button.contentHorizontalAlignment = .trailing
            return button
        } else {
            let label = UILabel()
            label.attributedText = NSAttributedString(string: asset.value ?? "",
                                                      style: asset.error == nil ? textStyle.value : textStyle.error)
            let huggingPriority = UILayoutPriority(UILayoutPriority.defaultLow.rawValue - 1)
            label.setContentHuggingPriority(huggingPriority, for: .horizontal)
            tooltipSource = TooltipSource(target: label)
            tooltipSource.message = tooltip
            return label
        }
    }

    @discardableResult
    func set(style: Style) -> FeeCalculationAssetLine {
        self.style = style
        return self
    }

    @discardableResult
    func set(name: String) -> FeeCalculationAssetLine {
        self.asset.name = name
        return self
    }

    @discardableResult
    func set(value: String) -> FeeCalculationAssetLine {
        self.asset.value = value
        return self
    }

    @discardableResult
    func set(tooltip: String?) -> FeeCalculationAssetLine {
        self.tooltip = tooltip
        return self
    }

    @discardableResult
    func set(button: String, target: AnyClass? = nil, action: Selector? = nil) -> FeeCalculationAssetLine {
        self.asset.button = ButtonItem(text: button, target: target, action: action, icon: nil)
        return self
    }

    @discardableResult
    func set(valueButton: String,
             icon: UIImage?,
             target: AnyClass? = nil,
             action: Selector? = nil) -> FeeCalculationAssetLine {
        self.asset.valueButton = ButtonItem(text: valueButton, target: target, action: action, icon: nil)
        return self
    }

    @discardableResult
    func set(error: Error?) -> FeeCalculationAssetLine {
        self.asset.error = error
        return self
    }

    override func equals(to rhs: FeeCalculationLine) -> Bool {
        guard let rhs = rhs as? FeeCalculationAssetLine else { return false }
        return style == rhs.style && asset == rhs.asset
    }

}
