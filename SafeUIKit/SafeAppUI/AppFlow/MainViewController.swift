//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class MainViewController: UIViewController {

    @IBOutlet weak var addressFieldLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceFieldLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

    struct Strings {
        static let addressLabel = LocalizedString("main.label.address", comment: "Address label")
        static let balanceLabel = LocalizedString("main.label.balance", comment: "Balance label")
    }

    static func create() -> MainViewController {
        return StoryboardScene.AppFlow.mainViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let service = ApplicationServiceRegistry.walletService
        if let balance = service.accountBalance(token: "ETH") {
            balanceLabel.text = "\(balance) Wei"
        }
        if let address = service.selectedWalletAddress {
            addressLabel.text = address
        }
    }

}
