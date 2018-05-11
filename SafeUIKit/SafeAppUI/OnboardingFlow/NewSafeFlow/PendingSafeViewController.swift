//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class PendingSafeViewController: UIViewController {

    @IBOutlet weak var titleLabel: H1Label!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var safeAddressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressStatusLabel: UILabel!

    static func create() -> PendingSafeViewController {
        return StoryboardScene.NewSafe.pendingSafeViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: precondition: safe in pending state
        // ethereumApplicationService.subscribeForBalanceUpdates(account: wallet.address)
        // ethereumApplicationService.subscribeFroTransactionUpdates(tx for safe creation)
        //
        // on transaction success: we're done, notify delegate - wallet.completeDeployment() - will go to main flow.
        // on transaction declined: fuckup, notify delegate - wallet.failDeployment()
        // on cancel: wallet.cancelDeployment(); ethereumApplicationService.cancelTransaction(tx); unsubscribe();
        // on balance update: if we're still pending & enough balance: stop balance updates; display we're deploying
        //  else if we're pending and not enough: please transfer more ether.
        //
    }

    @IBAction func cancel(_ sender: Any) {
    }

}
