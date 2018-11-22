//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class ContainerCell: UITableViewCell {

    public var cellContentView: UIView { return UIView() }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    private func commonInit() {
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellContentView)
        NSLayoutConstraint.activate([
            cellContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellContentView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
    }

}
