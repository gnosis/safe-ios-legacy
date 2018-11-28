//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

open class ContainerCell: UITableViewCell {

    open var cellContentView: UIView { return UIView() }
    open var horizontalMargin: CGFloat { return 0 }
    open var verticalMargin: CGFloat { return 0 }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    open func commonInit() {
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellContentView)
        NSLayoutConstraint.activate([
            cellContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalMargin),
            cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalMargin),
            cellContentView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -horizontalMargin),
            cellContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalMargin)])
    }

}
