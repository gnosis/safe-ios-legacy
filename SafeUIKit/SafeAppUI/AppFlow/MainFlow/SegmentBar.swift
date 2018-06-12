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

        selectionMarker.frame = CGRect(x: 0, y: 0, width: 10, height: 2)
        selectionMarker.backgroundColor = ColorName.azure.color
    }

    private func update() {
        let buttons = items.enumerated().map { index, item -> UIButton in
            let button = UIButton(type: UIButtonType.custom)
            button.setTitle(item.title, for: .normal)
            button.setTitleColor(ColorName.darkSlateBlue.color, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium)
            button.setImage(item.image, for: .normal)
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
        selectionMarker.removeFromSuperview()
        guard let selected = selectedItem, let index = items.index(of: selected) else { return }
        let view = stackView.arrangedSubviews[index]
        selectionMarker.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionMarker)
        NSLayoutConstraint.activate(
            [
            selectionMarker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            selectionMarker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectionMarker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            selectionMarker.heightAnchor.constraint(equalToConstant: 2)
            ])
        setNeedsUpdateConstraints()
        setNeedsLayout()
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
