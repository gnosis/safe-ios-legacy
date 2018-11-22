//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionHeaderCell: ContainerCell {

    public let transactionHeaderView = TransactionHeaderView()
    public override var cellContentView: UIView { return transactionHeaderView }

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
