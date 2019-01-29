//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

public class FeeCalculationView: UIView {

    var calculation = FeeCalculation()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public func commonInit() {
        calculation = FeeCalculation([FeeCalculationSection([
            FeeCalculationAssetLine(style: .balance,
                                    item: "Current balance",
                                    value: "- ETH"),
            FeeCalculationAssetLine(style: .plain,
                                    item: "Network fee",
                                    value: "- ETH",
                                    info: (text: "[?]", target: nil, action: nil)),
            FeeCalculationSpacingLine(spacing: 12),
            FeeCalculationAssetLine(style: .balance,
                                    item: "Balance",
                                    value: "- ETH")
        ])])
        let contentView = calculation.makeView()
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            heightAnchor.constraint(equalTo: contentView.heightAnchor)])
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

        let stackView = UIStackView(arrangedSubviews: elements.map { $0.makeView() })
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)])
        return backgroundView
    }

}

public class FeeCalculationSection: ArrayBasedCollection<FeeCalculationLine> {

    var backgroundColor: UIColor = .white
    var horizontalEdgeMargin: Double = 16
    var verticalEdgeMargin: Double = 22
    var showsBorder: Bool = true
    var topBorderWidth: Double = 1
    var topBorderColor: UIColor = ColorName.silver.color

    public func makeView() -> UIView {
        let backgroundView = UIView()
        backgroundView.backgroundColor = backgroundColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: elements.map { $0.makeView() })
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor,
                                               constant: CGFloat(horizontalEdgeMargin)),
            stackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor,
                                                constant: CGFloat(-horizontalEdgeMargin)),
            stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor,
                                           constant: CGFloat(verticalEdgeMargin)),
            backgroundView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor,
                                                   constant: CGFloat(verticalEdgeMargin))
        ])

        if showsBorder {
            let borderView = UIView()
            borderView.translatesAutoresizingMaskIntoConstraints = false
            borderView.backgroundColor = topBorderColor
            backgroundView.addSubview(borderView)

            NSLayoutConstraint.activate([
                borderView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
                borderView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
                borderView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                borderView.heightAnchor.constraint(equalToConstant: CGFloat(topBorderWidth))])
        }
        return backgroundView
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

    var style: Style

    typealias InfoItem = (text: String, target: Any?, action: Selector?)

    var info: InfoItem?

    init(style: Style, item: String, value: String) {
        self.style = style
        self.item = item
        self.value = value
    }

    convenience init(style: Style, item: String, value: String, info: InfoItem) {
        self.init(style: style, item: item, value: value)
        self.info = info
    }

    struct TextStyle {
        var item: AttributedStringStyle
        var value: AttributedStringStyle
        var info: AttributedStringStyle
        var error: AttributedStringStyle
    }

    var plainTextStyle = TextStyle(item: DefaultItemStyle(),
                                   value: DefaultValueStyle(),
                                   info: InfoItemStyle(),
                                   error: DefaultErrorStyle())

    var balanceTextStyle = TextStyle(item: BalanceItemStyle(),
                                     value: BalanceValueStyle(),
                                     info: BalanceInfoItemStyle(),
                                     error: DefaultErrorStyle())

    var item: String
    var value: String

    func setError(_ error: Error?) {}

    override func makeView() -> UIView {
        let textStyle = self.style == .plain ? plainTextStyle : balanceTextStyle

        let itemStack = UIStackView()
        let itemLabel = UILabel()
        itemLabel.attributedText = NSAttributedString(string: item, style: textStyle.item)
        itemStack.addArrangedSubview(itemLabel)
        if let info = self.info {
            let infoButton = UIButton(type: .custom)
            infoButton.setAttributedTitle(NSAttributedString(string: info.text, style: textStyle.info), for: .normal)
            if let action = info.action {
                infoButton.addTarget(info.target, action: action, for: .touchUpInside)
            }
            itemStack.addArrangedSubview(infoButton)
        }

        let valueLabel = UILabel()
        valueLabel.attributedText = NSAttributedString(string: value, style: textStyle.value)
        let stackPriority = itemStack.contentHuggingPriority(for: .horizontal).rawValue
        valueLabel.setContentHuggingPriority(UILayoutPriority(stackPriority - 1), for: .horizontal)

        let lineStack = UIStackView(arrangedSubviews: [itemStack, valueLabel])
        lineStack.translatesAutoresizingMaskIntoConstraints = false
        lineStack.heightAnchor.constraint(equalToConstant: CGFloat(lineHeight)).isActive = true
        return lineStack
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
