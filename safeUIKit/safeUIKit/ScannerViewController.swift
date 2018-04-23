//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import RSBarcodes
import AVFoundation

protocol ScannerDelegate: class {
    func didScan(_ code: String)
}

final class ScannerViewController: UIViewController {

    private weak var delegate: ScannerDelegate?

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

        var codeReaderVC: UIViewController
        #if DEBUG
            codeReaderVC = UIViewController()
            codeReaderVC.view.backgroundColor = .green
        #else
            codeReaderVC = RSCodeReaderViewController()
            codeReaderVC.barcodesHandler = barcodesHandler
        #endif

        codeReaderVC.willMove(toParentViewController: self)
        addChildViewController(codeReaderVC)
        view.insertSubview(codeReaderVC.view, at: 0)
        codeReaderVC.didMove(toParentViewController: self)
    }

    private func barcodesHandler(_ barcodes: [AVMetadataMachineReadableCodeObject]) {}

}
