//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit

class TransactionsEmptyView: BaseCustomView {

    var text: String = LocalizedString("empty_safe_transactions_message", comment: "No transactions yet") {
        didSet { update() }
    }

    var backgroundView: UIView!
    var textLabel: UILabel!

    override func commonInit() {
        backgroundView = ShadowWrapperView(frame: CGRect.zero)
        backgroundView.backgroundColor = .white
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        textLabel = UILabel(frame: CGRect.zero)
        textLabel.backgroundColor = .clear
        textLabel.font = UIFont.systemFont(ofSize: 28, weight: .light)
        textLabel.textAlignment = .center
        textLabel.textColor = ColorName.darkSlateBlue.color
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -15),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -94)])
        update()
    }

    override func update() {
        textLabel.text = "¯\\_(ツ)_/¯\n" + text
    }

}
