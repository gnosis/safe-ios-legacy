//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class AddTokenHeaderView: UITableViewHeaderFooterView {

    static let height: CGFloat = 35

    let label = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundView = UIView()
        backgroundView?.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate(
            [
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
                label.topAnchor.constraint(equalTo: topAnchor, constant: 3),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 3)
            ])
    }

}
