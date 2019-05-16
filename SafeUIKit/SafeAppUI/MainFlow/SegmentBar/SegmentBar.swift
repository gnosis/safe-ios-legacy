//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

public class SegmentBar: UIControl {

    public var items = [SegmentBarItem]() {
        didSet {
            if oldValue != items {
                update()
            }
        }
    }

    public var selectedItem: SegmentBarItem? {
        willSet {
            precondition(newValue == nil || items.contains(newValue!))
        }
        didSet {
            if oldValue != selectedItem {
                updateSelection()
            }
        }
    }

    private let stackView = UIStackView()
    private let selectionMarker = UIView()
    private let bottomLineHeight: CGFloat = 2
    private let selectionMarkerHeight: CGFloat = 6
    private let titleFontSize: CGFloat = 13
    var buttons = [UIButton]()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        stackView.frame = frame
        stackView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)

        let bottomLine = UIView()
        bottomLine.backgroundColor = ColorName.aquaBlue.color
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomLine)
        NSLayoutConstraint.activate(
            [
                bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
                bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
                bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
                bottomLine.heightAnchor.constraint(equalToConstant: bottomLineHeight)
            ])

        selectionMarker.backgroundColor = ColorName.aquaBlue.color
    }

    private func update() {
        buttons = items.enumerated().map { index, item -> UIButton in
            let button = UIButton(type: UIButton.ButtonType.custom)
            button.setTitle(" " + item.title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.black, for: .highlighted)
            button.setImage(item.image, for: .normal)
            button.tintColor = .black
            button.titleLabel?.font = UIFont.systemFont(ofSize: titleFontSize, weight: UIFont.Weight.regular)
            button.backgroundColor = .white
            button.tag = index
            button.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
            return button
        }
        let toRemove = stackView.arrangedSubviews
        toRemove.forEach { stackView.removeArrangedSubview($0) }
        buttons.forEach { stackView.addArrangedSubview($0) }
        selectedItem = nil
        setNeedsLayout()
    }

    private func updateSelection() {
        removeSelectionMarker()
        guard let selected = selectedItem, let selectedItemIndex = items.firstIndex(of: selected) else { return }
        buttons.forEach { configureDeselectedButton($0) }
        configureSelectedButton(at: selectedItemIndex)
        setNeedsUpdateConstraints()
        setNeedsLayout()
    }

    private func configureSelectedButton(at index: Int) {
        let button = buttons[index]
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        addSelectionMarker(at: index)
    }

    private func configureDeselectedButton(_ button: UIButton) {
        button.setTitleColor(ColorName.lightGreyBlue.color, for: .normal)
        button.tintColor = ColorName.lightGreyBlue.color
    }

    private func addSelectionMarker(at index: Int) {
        let button = buttons[index]
        selectionMarker.translatesAutoresizingMaskIntoConstraints = false
        selectionMarker.layer.cornerRadius = selectionMarkerHeight / 2
        selectionMarker.clipsToBounds = true
        let topLeftCorner = CACornerMask.layerMinXMinYCorner
        let topRightCorner = CACornerMask.layerMaxXMinYCorner
        switch index {
        case 0:
            selectionMarker.layer.maskedCorners = topRightCorner
        case buttons.count - 1:
            selectionMarker.layer.maskedCorners = topLeftCorner
        default:
            selectionMarker.layer.maskedCorners = [topLeftCorner, topRightCorner]
        }
        addSubview(selectionMarker)
        NSLayoutConstraint.activate(
            [
                selectionMarker.bottomAnchor.constraint(equalTo: button.bottomAnchor),
                selectionMarker.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                selectionMarker.trailingAnchor.constraint(equalTo: button.trailingAnchor),
                selectionMarker.heightAnchor.constraint(equalToConstant: selectionMarkerHeight)
            ])
    }

    private func removeSelectionMarker() {
        selectionMarker.removeFromSuperview()
    }

    @objc private func didTapButton(sender: UIButton) {
        selectedItem = items[sender.tag]
        sendActions(for: .valueChanged)
    }

}

public struct SegmentBarItem: Equatable {

    public var title: String
    public var image: UIImage?

    public init(title: String, image: UIImage? = nil) {
        self.title = title
        self.image = image
    }

}
