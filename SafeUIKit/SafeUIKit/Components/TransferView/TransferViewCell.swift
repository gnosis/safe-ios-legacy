//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public class TransferViewCell: UITableViewCell {

    public let transferView = TransferView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    private func commonInit() {
        transferView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(transferView)
        NSLayoutConstraint.activate([
            transferView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            transferView.topAnchor.constraint(equalTo: contentView.topAnchor),
            transferView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            transferView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
    }

}
