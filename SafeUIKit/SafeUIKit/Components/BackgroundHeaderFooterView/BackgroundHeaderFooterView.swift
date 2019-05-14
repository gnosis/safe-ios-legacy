//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

open class BackgroundHeaderFooterView: UITableViewHeaderFooterView {

    public static let height: CGFloat = 46

    private let label = UILabel()

    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public var title: String? {
        didSet {
            guard let title = title else {
                label.attributedText = nil
                return
            }
            label.attributedText = NSAttributedString(string: title, style: TableHeaderStyle())
        }
    }

    open func commonInit() {
        backgroundView = UIView()
        backgroundView!.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)])
    }

}
