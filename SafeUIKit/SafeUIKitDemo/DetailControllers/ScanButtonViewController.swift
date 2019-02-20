//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class ScanButtonViewController: UIViewController {

    @IBOutlet weak var scannedCodeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        scannedCodeLabel.text = nil
        let barButtonItem = ScanBarButtonItem(title: "Scan")
        barButtonItem.delegate = self
        barButtonItem.addDebugButtonToScannerController(title: "Scan Test Value", scanValue: "Test Value")
        navigationItem.rightBarButtonItem = barButtonItem
    }

}

extension ScanButtonViewController: ScanBarButtonItemDelegate {

    func scanBarButtonItemWantsToPresentController(_ controller: UIViewController) {
        present(controller, animated: true)
    }

    func scanBarButtonItemDidScanValidCode(_ code: String) {
        scannedCodeLabel.text = code
    }

}
