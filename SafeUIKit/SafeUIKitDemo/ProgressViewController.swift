//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class ProgressViewController: UIViewController {

    @IBOutlet weak var progressView1: ProgressView!
    @IBOutlet weak var progressView2: ProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView1.isIndeterminate = true
        progressView2.isError = true
    }

    @IBAction func toggle(_ sender: UIButton) {
        if progressView1.isAnimating {
            progressView1.stopAnimating()
            sender.setTitle("Start", for: .normal)
        } else {
            progressView1.beginAnimating()
            sender.setTitle("Stop", for: .normal)
        }
    }
}
