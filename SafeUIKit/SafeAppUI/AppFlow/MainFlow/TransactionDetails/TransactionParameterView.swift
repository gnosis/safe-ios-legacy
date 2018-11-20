//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class TransactionParameterView: DesignableView {

    var name: String = "Parameter" {
        didSet { setNeedsUpdate() }
    }
    var value: String = "Value of a transaction parameter" {
        didSet { setNeedsUpdate() }
    }

    var nameLabel: UILabel!
    var valueLabel: UILabel!

    override func commonInit() {
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        nameLabel.textColor = ColorName.darkSlateBlue.color

        valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 13)
        valueLabel.textColor = ColorName.battleshipGrey.color
        valueLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [nameLabel, valueLabel])
        stack.axis = .vertical
        stack.frame = self.bounds
        stack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(stack)

        didLoad()
    }

    override func update() {
        nameLabel.text = name
        valueLabel.text = value
    }

}
