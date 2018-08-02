//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeAppUI

class ProgressViewController: UIViewController {

    @IBOutlet weak var progressView: ProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.isIndeterminate = true
    }

    @IBAction func toggle(_ sender: UIButton) {
        if progressView.isAnimating {
            progressView.stopAnimating()
            sender.setTitle("Start", for: .normal)
        } else {
            progressView.beginAnimating()
            sender.setTitle("Stop", for: .normal)
        }
    }
}
