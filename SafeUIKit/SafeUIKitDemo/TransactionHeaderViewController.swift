//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

// swiftlint:disable line_length
class TransactionHeaderViewController: UIViewController {

    @IBOutlet weak var transactionHeader1: TransactionHeaderView!
    @IBOutlet weak var transactionHeader2: TransactionHeaderView!

    override func viewDidLoad() {
        super.viewDidLoad()

        transactionHeader1.assetImageURL = URL(string: "https://raw.githubusercontent.com/rmeissner/crypto_resources/master/tokens/rinkeby/icons/0x979861dF79C7408553aAF20c01Cfb3f81CCf9341.png")
        transactionHeader1.assetCode = "OLY"
        transactionHeader1.assetInfo = "Outgoing transfer"

        transactionHeader2.assetImage = UIImage(named: "gnosis-icon")
        transactionHeader2.assetCode = "GNO"
        transactionHeader2.assetInfo = "123.12345678"
    }

}
