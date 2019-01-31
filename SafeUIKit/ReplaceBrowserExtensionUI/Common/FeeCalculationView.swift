//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

public class FeeCalculationView: UIView {

    var calculation = FeeCalculation()
    var contentView: UIView!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public func commonInit() {
        update()
    }

    func update() {
        contentView?.removeFromSuperview()
        contentView = calculation.makeView()
        addSubview(contentView)
        wrapAroundDynamiHeightView(contentView)
    }

}


open class ArrayBasedCollection<ElementType>: MutableCollection, RangeReplaceableCollection, RandomAccessCollection {

    var elements: [ElementType] = []

    required public init() {}

    // Collection / Mutable Collection

    private func isInBounds(index: Int) -> Bool {
        return (0..<count).contains(index)
    }

    public var startIndex: Int {
        return elements.startIndex
    }

    public var endIndex: Int {
        return elements.endIndex
    }

    public subscript(index: Int) -> ElementType {
        get {
            return elements[index]
        }
        set {
            elements[index] = newValue
        }
    }

    public func index(after i: Int) -> Int {
        return elements.index(after: i)
    }

    // RangeReplaceableCollection

    public func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, ElementType == C.Element, Int == R.Bound {
            elements.replaceSubrange(subrange, with: newElements)
    }
}



public class FeeCalculation: ArrayBasedCollection<FeeCalculationSection> {

    public func makeView() -> UIView {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSections(to: backgroundView)
        return backgroundView
    }

    private func addSections(to backgroundView: UIView) {
        let stackView = UIStackView(arrangedSubviews: elements.map { $0.makeView() })
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)])
    }

}

public class FeeCalculationSection: ArrayBasedCollection<FeeCalculationLine> {

    var backgroundColor: UIColor = .white
    var insets = UIEdgeInsets(top: 22, left: 16, bottom: 22, right: 16)
    var border: (width: Double, color: UIColor)? = (1, ColorName.silver.color)

    public func makeView() -> UIView {
        let backgroundView = UIView()
        backgroundView.backgroundColor = backgroundColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addLines(to: backgroundView)
        addBorder(to: backgroundView)
        return backgroundView
    }

    private func addLines(to backgroundView: UIView) {
        let stackView = UIStackView(arrangedSubviews: elements.map { $0.makeView() })
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stackView)
        backgroundView.wrapAroundDynamicHeightView(stackView, insets: insets)
    }

    private func addBorder(to backgroundView: UIView) {
        guard let border = self.border else { return }
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = border.color
        backgroundView.addSubview(borderView)
        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            borderView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            borderView.heightAnchor.constraint(equalToConstant: CGFloat(border.width))])
    }

}

public class FeeCalculationLine {

    var lineHeight: Double = 25

    func makeView() -> UIView {
        return UIView()
    }

}

public class FeeCalculationSpacingLine: FeeCalculationLine {

    var spacing: Double

    init(spacing: Double) {
        self.spacing = spacing
    }

    override func makeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: CGFloat(spacing)).isActive = true
        return view
    }

}

public class FeeCalculationAssetLine: FeeCalculationLine {

    enum Style {
        case plain
        case balance
    }

    typealias InfoItem = (text: String, target: Any?, action: Selector?)

    var style: Style
    var item: String
    var value: String
    var info: InfoItem?

    init(style: Style, item: String, value: String) {
        self.style = style
        self.item = item
        self.value = value
    }

    func setError(_ error: Error?) {}

    override func makeView() -> UIView {
        let textStyle = self.style == .plain ? TextStyle.plain : TextStyle.balance
        let lineStack = UIStackView(arrangedSubviews: [makeItem(textStyle: textStyle), makeValue(textStyle: textStyle)])
        lineStack.translatesAutoresizingMaskIntoConstraints = false
        lineStack.heightAnchor.constraint(equalToConstant: CGFloat(lineHeight)).isActive = true
        return lineStack
    }

    func makeItem(textStyle: TextStyle) -> UIView {
        let itemStack = UIStackView()
        let itemLabel = UILabel()
        itemLabel.attributedText = NSAttributedString(string: item, style: textStyle.item)
        itemStack.addArrangedSubview(itemLabel)
        if let info = self.info {
            itemStack.addArrangedSubview(makeInfoButton(info: info, textStyle: textStyle))
        }
        return itemStack
    }

    func makeInfoButton(info: InfoItem, textStyle: TextStyle) -> UIButton {
        let infoButton = UIButton(type: .custom)
        infoButton.setAttributedTitle(NSAttributedString(string: info.text, style: textStyle.info), for: .normal)
        if let action = info.action {
            infoButton.addTarget(info.target, action: action, for: .touchUpInside)
        }
        return infoButton
    }

    func makeValue(textStyle: TextStyle) -> UIView {
        let valueLabel = UILabel()
        valueLabel.attributedText = NSAttributedString(string: value, style: textStyle.value)
        let huggingPriority = UILayoutPriority(UILayoutPriority.defaultLow.rawValue - 1)
        valueLabel.setContentHuggingPriority(huggingPriority, for: .horizontal)
        return valueLabel
    }

}

extension FeeCalculationAssetLine {

    struct TextStyle {
        var item: AttributedStringStyle
        var value: AttributedStringStyle
        var info: AttributedStringStyle
        var error: AttributedStringStyle

        static let plain = TextStyle(item: DefaultItemStyle(),
                                     value: DefaultValueStyle(),
                                     info: InfoItemStyle(),
                                     error: DefaultErrorStyle())

        static let balance = TextStyle(item: BalanceItemStyle(),
                                       value: BalanceValueStyle(),
                                       info: BalanceInfoItemStyle(),
                                       error: DefaultErrorStyle())
    }

    class DefaultItemStyle: AttributedStringStyle {

        override var fontSize: Double { return 16 }
        override var minimumLineHeight: Double { return 25 }
        override var maximumLineHeight: Double { return 25 }
        override var fontColor: UIColor { return ColorName.battleshipGrey.color }

    }

    class BalanceItemStyle: DefaultItemStyle {

        override var fontWeight: UIFont.Weight { return .bold }

    }

    class InfoItemStyle: DefaultItemStyle {

        override var fontColor: UIColor { return ColorName.aquaBlue.color }

    }

    class BalanceInfoItemStyle: InfoItemStyle {

        override var fontWeight: UIFont.Weight { return .bold }

    }

    class DefaultValueStyle: DefaultItemStyle {

        override var alignment: NSTextAlignment { return .right }

    }

    class BalanceValueStyle: DefaultValueStyle {

        override var fontWeight: UIFont.Weight { return .bold }

    }

    class DefaultErrorStyle: DefaultItemStyle {}

}

public class FeeCalculationErrorLine: FeeCalculationLine {

    init(text: String) {}

    var textStyle: AttributedStringStyle?

}
