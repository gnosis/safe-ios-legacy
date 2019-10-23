//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class AddressBookEntryTableViewCell: UITableViewCell {

    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: EthereumAddressLabel!

    func configure(entry: AddressBookEntry) {
        identiconView.seed = entry.address
        addressLabel.address = entry.address
        nameLabel.text = entry.name
    }

}
