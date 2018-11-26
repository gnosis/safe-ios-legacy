//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class TransactionConfirmationViewController: UIViewController {

    @IBOutlet weak var transactionConfirmationView: TransactionConfirmationView!
    @IBOutlet weak var transactionConfirmationView1: TransactionConfirmationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        transactionConfirmationView.status = .undefined
        transactionConfirmationView1.status = .undefined
    }

    override func viewDidAppear(_ animated: Bool) {
        transactionConfirmationView.status = .pending
        transactionConfirmationView1.status = .pending
    }

    @IBAction func confirm(_ sender: Any) {
        transactionConfirmationView.status = .confirmed
    }

    @IBAction func reject(_ sender: Any) {
        transactionConfirmationView1.status = .rejected
    }

}
