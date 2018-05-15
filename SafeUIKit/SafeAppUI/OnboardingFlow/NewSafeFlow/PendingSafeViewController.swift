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
    }

    @IBAction func cancel(_ sender: Any) {
    }

}
