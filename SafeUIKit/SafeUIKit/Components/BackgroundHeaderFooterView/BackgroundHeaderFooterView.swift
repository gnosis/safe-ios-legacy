//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

open class BackgroundHeaderFooterView: UITableViewHeaderFooterView {

    public static let height: CGFloat = 35

    public let label = UILabel()

    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    open func commonInit() {
        backgroundView = UIView()
        backgroundView?.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate(
            [
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
                label.topAnchor.constraint(equalTo: topAnchor, constant: 3),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3)
            ])
    }

}
