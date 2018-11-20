//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit

class TransactionsEmptyView: BaseCustomView {

    var text: String = LocalizedString("transactions.empty.text", comment: "No transactions yet") {
        didSet { setNeedsUpdate() }
    }

    var textLabel: UILabel!

    override func commonInit() {
        backgroundColor = ColorName.paleGreyThree.color
        textLabel = UILabel(frame: CGRect.zero)
        textLabel.backgroundColor = .clear
        textLabel.font = UIFont.systemFont(ofSize: 28, weight: .light)
        textLabel.textAlignment = .center
        textLabel.textColor = ColorName.darkSlateBlue.color
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30)])
        didLoad()
    }

    override func update() {
        textLabel.text = text
    }

}
