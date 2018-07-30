//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class FundsTransferTransactionViewController: UIViewController {

    @IBOutlet weak var participantView: TransactionParticipantView!
    @IBOutlet weak var valueView: TransactionValueView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var recipientTextField: UITextField!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var continueButton: BorderedButton!

    static func create() -> FundsTransferTransactionViewController {
        return StoryboardScene.Main.fundsTransferTransactionViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
