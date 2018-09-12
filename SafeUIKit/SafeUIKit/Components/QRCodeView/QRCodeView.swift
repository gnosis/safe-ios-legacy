//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import RSBarcodes
import AVFoundation

final public class QRCodeView: DesignableView {

    @IBInspectable
    public var value: String? {
        didSet {
            update()
        }
    }

    internal let imageView = UIImageView()

    override public func commonInit() {
        imageView.accessibilityIdentifier = "qr code"
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(imageView)
        didLoad()
    }

    override public func update() {
        guard let value = value else { return }
        let generator = RSUnifiedCodeGenerator.shared
        generator.fillColor = UIColor.white
        generator.strokeColor = UIColor.black
        if let image = generator.generateCode(
            value, machineReadableCodeObjectType: AVMetadataObject.ObjectType.qr.rawValue) {
            imageView.image = RSAbstractCodeGenerator.resizeImage(
                image, targetSize: imageView.bounds.size, contentMode: .scaleAspectFit)
        }
    }

}
