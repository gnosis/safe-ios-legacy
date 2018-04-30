//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit

class QRCodeInputViewController: UIViewController {

    private var scannerController: UIViewController?

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
        barcodeInput.qrCodeConverter = { $0 }
    }

}

extension QRCodeInputViewController: QRCodeInputDelegate {

    func didScanValidCode() {
        scannerController?.dismiss(animated: true)
    }

    func presentScannerController(_ controller: UIViewController) {
        scannerController = controller
        present(controller, animated: true)
    }

    func presentCameraRequiredAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }

}
