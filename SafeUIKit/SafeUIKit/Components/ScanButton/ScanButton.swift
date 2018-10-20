//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol ScanButtonDelegate: class {
    func presentController(_ controller: UIViewController)
    func didScanValidCode(_ button: ScanButton, code: String)
}

public final class ScanButton: CheckmarkButton {

    public weak var delegate: ScanButtonDelegate?
    public var scanValidatedConverter: ScanValidatedConverter? {
        didSet {
            scanHandler.scanValidatedConverter = scanValidatedConverter
        }
    }
    var scanHandler = ScanQRCodeHandler()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        scanHandler.delegate = self
        addTarget(self, action: #selector(scan), for: .touchUpInside)
    }

    @objc private func scan() {
        scanHandler.scan()
    }

    public func addDebugButtonToScannerController(title: String, scanValue: String) {
        scanHandler.addDebugButtonToScannerController(title: title, scanValue: scanValue)
    }

}

extension ScanButton: ScanQRCodeHandlerDelegate {

    func presentController(_ controller: UIViewController) {
        delegate?.presentController(controller)
    }

    func didScanCode(raw: String, converted: String?) {
        self.delegate?.didScanValidCode(self, code: raw)
    }

}
