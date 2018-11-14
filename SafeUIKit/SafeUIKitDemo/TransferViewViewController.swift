//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

class TransferViewViewController: UIViewController {

    @IBOutlet weak var transferView: TransferView!

    override func viewDidLoad() {
        super.viewDidLoad()
        transferView.toAddress = "0x777cafe9fb8cc2218fb12a9a2d9335193caa0777"
        transferView.fromAddress = "0x888cafe9fb8cc2218fb12a9a2d9335193caa0888"
        transferView.tokenData = TokenData(
            address: "", code: "TEST", name: "", logoURL: "", decimals: 5, balance: 123456)
    }

}
