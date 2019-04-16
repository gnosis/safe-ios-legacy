//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import RSBarcodes
import AVFoundation
import Common

protocol ScannerDelegate: class {
    func didScan(_ code: String) throws -> Bool
}

enum ScannerTrackingEvent: String, ScreenTrackingEvent {
    case error = "Onboarding_2FAScanError"
}

class ScannerViewController: UIViewController {

    enum Strings {
        static let errorTitle = LocalizedString("error", comment: "Error")
        static let errorOK = LocalizedString("ok", comment: "OK")
    }

    weak var delegate: ScannerDelegate?

    @IBOutlet weak var debugButtonsStackView: UIStackView!
    @IBOutlet weak var closeButton: UIButton!

    private var debugButtonReturnCodes = [String]()
    private var debugButtons = [UIButton]()
    private var shouldStopHandling: Bool = false

    static func create(delegate: ScannerDelegate) -> ScannerViewController {
        let bundle = Bundle(for: ScannerViewController.self)
        let controller = ScannerViewController(nibName: "ScannerViewController", bundle: bundle)
        controller.delegate = delegate
        return controller
    }

    @IBAction func close() {
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

        closeButton.accessibilityLabel = LocalizedString("close", comment: "Close button on camera")
    }

    func barcodesHandler(_ barcodes: [AVMetadataMachineReadableCodeObject]) {
        guard !shouldStopHandling else { return }
        for barcode in barcodes.filter({ $0.type == .qr && $0.stringValue != nil }) {
            if handle(barcode.stringValue!) {
                break
            }
        }
    }

    func handle(_ barcode: String) -> Bool {
        guard let delegate = delegate else { return false }
        do {
            shouldStopHandling = try delegate.didScan(barcode)
            return shouldStopHandling
        } catch {
            show(error: error)
            return true
        }
    }

    private func show(error: Error) {
        Tracker.shared.track(event: ScannerTrackingEvent.error)
        let alert = UIAlertController(title: Strings.errorTitle,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.errorOK, style: .default, handler: nil)
        alert.addAction(okAction)
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            present(alert, animated: true, completion: nil)
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
        _ = handle(code)
    }

}
