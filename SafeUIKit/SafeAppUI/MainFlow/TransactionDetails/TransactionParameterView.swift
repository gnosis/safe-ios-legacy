//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class TransactionParameterView: BaseCustomView {

    var name: String = "Parameter" {
        didSet { update() }
    }
    var value: String = "Value of a transaction parameter" {
        didSet { update() }
    }

    var nameLabel: UILabel!
    var valueLabel: UILabel!
    private let padding: CGFloat = 16

    internal func newValueLabel() -> UILabel {
        return UILabel()
    }

    override func commonInit() {
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = ColorName.darkSlateBlue.color

        valueLabel = newValueLabel()
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.textColor = ColorName.battleshipGrey.color
        valueLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [nameLabel, valueLabel])
        stack.axis = .vertical
        stack.frame = self.bounds
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 4
        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: stack.heightAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)])

        update()
    }

    override func update() {
        nameLabel.text = name
        valueLabel.text = value
    }

}
