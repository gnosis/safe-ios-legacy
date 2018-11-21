//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionHeaderCell: UITableViewCell {

    public let transactionHeaderView = TransactionHeaderView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    private func commonInit() {
        transactionHeaderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(transactionHeaderView)
        NSLayoutConstraint.activate([
            transactionHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            transactionHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            transactionHeaderView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            transactionHeaderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
    }

    public func configure(imageURL: URL?, code: String, info: String) {
        if let imageURL = imageURL {
            transactionHeaderView.assetImageURL = imageURL
        } else {
            transactionHeaderView.assetImage = Asset.TokenIcons.eth.image
        }
        transactionHeaderView.assetCode = code
        transactionHeaderView.assetInfo = info
    }

}
