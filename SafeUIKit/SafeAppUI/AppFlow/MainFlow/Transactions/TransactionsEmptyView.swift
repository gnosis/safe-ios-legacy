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

    var backgroundView: UIView!
    var textLabel: UILabel!

    override func commonInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        backgroundView = ShadowWrapperView(frame: CGRect.zero)
        backgroundView.backgroundColor = ColorName.paleGreyThree.color
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
        didLoad()
    }

    override func update() {
        textLabel.text = text
    }

}
