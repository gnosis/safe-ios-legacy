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

    private var debugButtonReturnCodes = [String]()
    private var debugButtons = [UIButton]()

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
        #else
        debugButtons.forEach {
            debugButtonsStackView.addArrangedSubview($0)
        }
        #endif

        var codeReaderVC: UIViewController
        if UIDevice.current.isSimulator {
            codeReaderVC = UIViewController()
            codeReaderVC.view.backgroundColor = .green
        } else {
            codeReaderVC = RSCodeReaderViewController()
            (codeReaderVC as! RSCodeReaderViewController).barcodesHandler = barcodesHandler
        }

        addChild(codeReaderVC)
        codeReaderVC.view.frame = view.frame
        view.insertSubview(codeReaderVC.view, at: 0)
        codeReaderVC.didMove(toParent: self)

        closeButton.accessibilityLabel = LocalizedString("camera.close", comment: "Close button on camera")
    }

    private func barcodesHandler(_ barcodes: [AVMetadataMachineReadableCodeObject]) {
        for barcode in barcodes.filter({ $0.type == .qr && $0.stringValue != nil }) {
            delegate?.didScan(barcode.stringValue!)
        }
    }

    func addDebugButton(title: String, scanValue: String) {
        let button = UIButton()
        button.tag = debugButtonReturnCodes.count
        button.setTitleColor(.red, for: .normal)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(scanDebugCode), for: .touchUpInside)
        debugButtonReturnCodes.append(scanValue)
        debugButtons.append(button)
    }

    @objc private func scanDebugCode(_ sender: UIButton) {
        let code = debugButtonReturnCodes[sender.tag]
        delegate?.didScan(code)
    }

}
