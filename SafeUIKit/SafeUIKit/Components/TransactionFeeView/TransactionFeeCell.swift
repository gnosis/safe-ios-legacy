//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionFeeCell: UITableViewCell {

    public let transactionFeeView = TransactionFeeView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    private func commonInit() {
        transactionFeeView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(transactionFeeView)
        NSLayoutConstraint.activate([
            transactionFeeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            transactionFeeView.topAnchor.constraint(equalTo: contentView.topAnchor),
            transactionFeeView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            transactionFeeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
    }

}
