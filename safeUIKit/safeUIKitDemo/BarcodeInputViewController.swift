//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit

class BarcodeInputViewController: UIViewController {

    @IBOutlet weak var barcodeInput: BarcodeInput!

    @IBAction func enable(_ sender: Any) {
        barcodeInput.editingMode = .scanAndType
    }

    @IBAction func disable(_ sender: Any) {
        barcodeInput.editingMode = .scanOnly
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        barcodeInput.barcodeDelegate = self
    }

}

extension BarcodeInputViewController: BarcodeInputDelegate {

    func presentBarcodeController(_ controller: UIViewController) {
        present(controller, animated: true)
    }

}
