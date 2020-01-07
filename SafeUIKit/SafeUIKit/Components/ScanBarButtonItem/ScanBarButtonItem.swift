//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol ScanBarButtonItemDelegate: class {
    func scanBarButtonItemWantsToPresentController(_ controller: UIViewController)
    func scanBarButtonItemDidScanValidCode(_ code: String)
}

public final class ScanBarButtonItem: UIBarButtonItem {

    public weak var delegate: ScanBarButtonItemDelegate?
    public var scanValidatedConverter: ScanValidatedConverter? {
        didSet {
            scanHandler.scanValidatedConverter = scanValidatedConverter
        }
    }
    var scanHandler = ScanQRCodeHandler()
    public var scanHeader: String? {
        set {
            scanHandler.header = newValue
        }
        get {
            return scanHandler.header
        }
    }
    public convenience init(title: String) {
        self.init(title: title, style: .done, target: nil, action: nil)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        scanHandler.delegate = self
        action = #selector(scan)
    }

    @objc public func scan() {
        scanHandler.scan()
    }

    public func addDebugButtonToScannerController(title: String, scanValue: String) {
        scanHandler.addDebugButtonToScannerController(title: title, scanValue: scanValue)
    }

}

extension ScanBarButtonItem: ScanQRCodeHandlerDelegate {

    public func presentController(_ controller: UIViewController) {
        delegate?.scanBarButtonItemWantsToPresentController(controller)
    }

    public func didScanCode(raw: String, converted: String?) {
        self.delegate?.scanBarButtonItemDidScanValidCode(raw)
    }

}
