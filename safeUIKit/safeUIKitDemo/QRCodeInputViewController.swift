//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit

class QRCodeInputViewController: UIViewController {

    @IBOutlet weak var barcodeInput: QRCodeInput!

    @IBAction func enable(_ sender: Any) {
        barcodeInput.editingMode = .scanAndType
    }

    @IBAction func disable(_ sender: Any) {
        barcodeInput.editingMode = .scanOnly
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        barcodeInput.qrCodeDelegate = self
    }

}

extension QRCodeInputViewController: QRCodeInputDelegate {

    func didScanValidCode() {}

    func presentScannerController(_ controller: UIViewController) {
        present(controller, animated: true)
    }

}
