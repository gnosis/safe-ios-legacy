//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

public class FeeCalculationAssetLine: FeeCalculationLine {

    public enum Style {
        case plain
        case balance
    }

    public struct AssetInfo: Equatable {

        public var name: String
        public var button: ButtonItem?
        public var value: String?
        /// If set, then valueButton is shown instead of value
        public var valueButton: ButtonItem?
        public var error: Error?

        public static let empty = AssetInfo(name: "", button: nil, value: "", valueButton: nil, error: nil)

        public static func == (lhs: FeeCalculationAssetLine.AssetInfo, rhs: FeeCalculationAssetLine.AssetInfo) -> Bool {
            return lhs.name == rhs.name &&
                lhs.button == rhs.button &&
                lhs.value == rhs.value &&
                String(describing: lhs.error) == String(describing: rhs.error)
        }

    }

    public struct ButtonItem: Equatable {

        public var text: String
        public weak var target: AnyObject?
        public var action: Selector?
        public var icon: UIImage?

        public static func == (lhs: FeeCalculationAssetLine.ButtonItem,
                               rhs: FeeCalculationAssetLine.ButtonItem) -> Bool {
            return lhs.text == rhs.text &&
                String(reflecting: lhs.target) == String(reflecting: rhs.target) &&
                String(describing: lhs.action) == String(describing: rhs.action)
        }

    }

    public var style: Style = .plain
    public var asset: AssetInfo = .empty
    private var tooltip: String?

    public private(set) var tooltipSource: TooltipSource!

    override func makeView() -> UIView {
        let textStyle = self.style == .plain ? TextStyle.plain : TextStyle.balance
        let lineStack = UIStackView(arrangedSubviews: [makeName(textStyle: textStyle),
                                                       makeValue(textStyle: textStyle)])
        lineStack.translatesAutoresizingMaskIntoConstraints = false
        lineStack.alignment = .firstBaseline
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
        let filler = UIView() // will get stretched between the button and the value
        let button = makeInfoButton(button: buttonData, textStyle: textStyle)
        let wrapper = UIStackView(arrangedSubviews: [label, button, filler])
        wrapper.spacing = 5
        wrapper.alignment = .firstBaseline
        return wrapper
    }

    func makeInfoButton(button buttonData: ButtonItem, textStyle: TextStyle) -> UIButton {
        let button = UIButton(type: .custom)
        button.setAttributedTitle(NSAttributedString(string: buttonData.text, style: textStyle.info),
                                  for: .normal)
        button.setAttributedTitle(NSAttributedString(string: buttonData.text, style: textStyle.infoPressed),
                                  for: .highlighted)
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        if let action = buttonData.action {
            button.addTarget(buttonData.target, action: action, for: .touchUpInside)
        }
        button.contentHorizontalAlignment = .left
        return button
    }

    func makeValue(textStyle: TextStyle) -> UIView {
        if let valueButton = asset.valueButton {
            return makeSettingsButton(textStyle: textStyle, item: valueButton)
        } else {
            let label = UILabel()
            label.attributedText = NSAttributedString(string: asset.value ?? "",
                                                      style: asset.error == nil ? textStyle.value :
                                                        textStyle.valueError)
            label.setContentHuggingPriority(.required, for: .horizontal)
            tooltipSource = TooltipSource(target: label)
            tooltipSource.message = tooltip
            return label
        }
    }

    public static let settingsButtonTag = 0x10

    private func makeSettingsButton(textStyle: TextStyle, item: ButtonItem) -> UIButton {
        let button = UIButton(type: .custom)
        button.setAttributedTitle(NSAttributedString(string: item.text, style: textStyle.valueButton),
                                  for: .normal)
        button.setAttributedTitle(NSAttributedString(string: item.text, style: textStyle.valueButtonPressed),
                                  for: .highlighted)
        if let action = item.action {
            button.addTarget(item.target, action: action, for: .touchUpInside)
        }

        button.setImage(Asset.settings.image, for: .normal)
        button.flipImageToTrailingSide(spacing: 7)
        button.contentHorizontalAlignment = .leading // instead of trailing, because the sides flipped
        button.addUnderline(color: textStyle.valueButton.fontColor, width: 1.0, offset: 1.0, pattern: [2, 2])
        button.tag = FeeCalculationAssetLine.settingsButtonTag

        return button
    }

    @discardableResult
    public func set(style: Style) -> FeeCalculationAssetLine {
        self.style = style
        return self
    }

    @discardableResult
    public func set(name: String) -> FeeCalculationAssetLine {
        self.asset.name = name
        return self
    }

    @discardableResult
    public func set(value: String) -> FeeCalculationAssetLine {
        self.asset.value = value
        return self
    }

    @discardableResult
    public func set(tooltip: String?) -> FeeCalculationAssetLine {
        self.tooltip = tooltip
        return self
    }

    @discardableResult
    public func set(button: String, target: AnyObject? = nil, action: Selector? = nil) -> FeeCalculationAssetLine {
        self.asset.button = ButtonItem(text: button, target: target, action: action, icon: nil)
        return self
    }

    @discardableResult
    public func set(valueButton: String,
                    icon: UIImage?,
                    target: AnyObject? = nil,
                    action: Selector? = nil) -> FeeCalculationAssetLine {
        self.asset.valueButton = ButtonItem(text: valueButton, target: target, action: action, icon: nil)
        return self
    }

    @discardableResult
    public func set(error: Error?) -> FeeCalculationAssetLine {
        self.asset.error = error
        return self
    }

    override func equals(to rhs: FeeCalculationLine) -> Bool {
        guard let rhs = rhs as? FeeCalculationAssetLine else { return false }
        return style == rhs.style && asset == rhs.asset
    }

}

public extension UIButton {

    /// Flips the button's view along vertical axis. This changes content alignment - .leading is not .trailing!
    ///
    /// This method modifies imageEdgeInsets and contentEdgeInsets
    ///
    /// brilliant trickery to make image appear on the right hand side of the button
    /// h/t https://stackoverflow.com/a/32174204/7822368
    func flipImageToTrailingSide(spacing: CGFloat) {
        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
    }

    // separate dash-line view because the NSAttributedString's dashed underline is too close to the
    // text vertically and there was no way found to offset it.
    func addUnderline(color: UIColor, width: CGFloat, offset: CGFloat, pattern: [Int]?) {
        let dashLine = DashedSeparatorView()
        dashLine.lineColor = color
        dashLine.lineWidth = width
        dashLine.pattern = pattern
        dashLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dashLine)
        NSLayoutConstraint.activate([
            dashLine.heightAnchor.constraint(equalToConstant: width),
            dashLine.leadingAnchor.constraint(equalTo: titleLabel!.leadingAnchor),
            dashLine.trailingAnchor.constraint(equalTo: titleLabel!.trailingAnchor),
            dashLine.topAnchor.constraint(equalTo: titleLabel!.bottomAnchor, constant: offset)])
    }

}
