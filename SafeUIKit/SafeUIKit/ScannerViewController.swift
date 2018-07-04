//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import RSBarcodes
import AVFoundation
import Common

protocol ScannerDelegate: class {
    func didScan(_ code: String)
}

final class ScannerViewController: UIViewController {

    private weak var delegate: ScannerDelegate?

    @IBOutlet weak var debugButtonsStackView: UIStackView!
    @IBOutlet weak var closeButton: UIButton!

    static func create(delegate: ScannerDelegate) -> ScannerViewController {
        let bundle = Bundle(for: ScannerViewController.self)
        let controller = ScannerViewController(nibName: "ScannerViewController", bundle: bundle)
        controller.delegate = delegate
        return controller
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        #if !DEBUG
            debugButtonsStackView.removeFromSuperview()
        #endif

        var codeReaderVC: UIViewController
        if UIDevice.current.isSimulator {
            codeReaderVC = UIViewController()
            codeReaderVC.view.backgroundColor = .green
        } else {
            codeReaderVC = RSCodeReaderViewController()
            (codeReaderVC as! RSCodeReaderViewController).barcodesHandler = barcodesHandler
        }

        addChildViewController(codeReaderVC)
        codeReaderVC.view.frame = view.frame
        view.insertSubview(codeReaderVC.view, at: 0)
        codeReaderVC.didMove(toParentViewController: self)

        closeButton.accessibilityLabel = LocalizedString("camera.close", comment: "Close button on camera")
    }

    private func barcodesHandler(_ barcodes: [AVMetadataMachineReadableCodeObject]) {
        for barcode in barcodes.filter({ $0.type == .qr && $0.stringValue != nil }) {
            delegate?.didScan(barcode.stringValue!)
        }
    }

    // MARK: - Debug Buttons

    private let validCodeTemplate = """
        {
            "expirationDate" : "%@",
            "signature": {
                "v" : 27,
                "r" : "15823297914388465068645274956031579191506355248080856511104898257696315269079",
                "s" : "38724157826109967392954642570806414877371763764993427831319914375642632707148"
            }
        }
        """

    private func validCode(timeIntervalSinceNow: TimeInterval) -> String {
        let dateStr = DateFormatter.networkDateFormatter.string(from: Date(timeIntervalSinceNow: timeIntervalSinceNow))
        return String(format: validCodeTemplate, dateStr)
    }

    @IBAction func debugScanRandomValidCode(_ sender: Any) {
        delegate?.didScan(validCode(timeIntervalSinceNow: 5 * 60))
    }

    @IBAction func debugScanInvalidCode(_ sender: Any) {
        delegate?.didScan("invalid_code")
    }

    @IBAction func debugScanTwoValidCodes(_ sender: Any) {
        delegate?.didScan(validCode(timeIntervalSinceNow: 5 * 60))
        delegate?.didScan(validCode(timeIntervalSinceNow: 6 * 60))
    }

}
