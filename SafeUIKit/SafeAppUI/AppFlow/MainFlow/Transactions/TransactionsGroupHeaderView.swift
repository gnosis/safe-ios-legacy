//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

class TransactionsGroupHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var headerLabel: UILabel!

    func configure(group: TransactionGroup) {
        headerLabel.text = group.name
        headerLabel.textColor = group.isPending ? ColorName.blueyGrey.color : ColorName.battleshipGrey.color
    }

}
