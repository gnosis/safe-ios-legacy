//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class ProgressViewController: UIViewController {

    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var progressView2: ProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.isIndeterminate = true
        progressView2.isError = true
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
