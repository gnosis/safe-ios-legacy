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
    private let selectionMarker = UIImageView()
    private let selectionMarkerHeight: CGFloat = 5
    private let titleFontSize: CGFloat = 14
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
        stackView.frame = bounds
        stackView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        selectionMarker.tintColor = ColorName.hold.color
        let shadowImage = UIImageView(image: Asset.shadow.image.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0))
        shadowImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shadowImage)
        NSLayoutConstraint.activate([shadowImage.topAnchor.constraint(equalTo: stackView.bottomAnchor),
                                     shadowImage.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                                     shadowImage.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                                     shadowImage.heightAnchor.constraint(equalToConstant: 10)])
        clipsToBounds = false
    }

    private func update() {
        buttons = items.enumerated().map { index, item -> UIButton in
            let button = UIButton(type: UIButton.ButtonType.custom)
            button.setTitle(" " + item.title, for: .normal)
            button.setTitleColor(ColorName.black.color, for: .normal)
            button.setTitleColor(ColorName.black.color, for: .highlighted)
            button.setImage(item.image, for: .normal)
            button.tintColor = ColorName.black.color
            button.titleLabel?.font = UIFont.systemFont(ofSize: titleFontSize, weight: UIFont.Weight.medium)
            button.backgroundColor = ColorName.snowwhite.color
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
        button.setTitleColor(ColorName.hold.color, for: .normal)
        button.tintColor = ColorName.hold.color
        addSelectionMarker(at: index)
    }

    private func configureDeselectedButton(_ button: UIButton) {
        button.setTitleColor(ColorName.mediumGrey.color, for: .normal)
        button.tintColor = ColorName.mediumGrey.color
    }

    private func addSelectionMarker(at index: Int) {
        let button = buttons[index]
        selectionMarker.translatesAutoresizingMaskIntoConstraints = false
        let leftIndex = 0
        let rightIndex = buttons.count - 1
        switch index {
        case leftIndex:
            selectionMarker.image = Asset.left.image
        case rightIndex:
            selectionMarker.image = Asset.right.image
        default:
            selectionMarker.image = Asset.middle.image
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
