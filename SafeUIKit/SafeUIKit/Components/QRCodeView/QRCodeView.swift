//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import RSBarcodes
import AVFoundation

final public class QRCodeView: BaseCustomView {

    public var value: String? {
        didSet {
            update()
        }
    }

    public var padding: CGFloat = 0 {
        didSet {
            guard padding > 0 && padding < bounds.width / 2 else { return }
            imageView.frame = CGRect(
                x: bounds.minX + padding,
                y: bounds.minY + padding,
                width: bounds.width - 2 * padding,
                height: bounds.height - 2 * padding)
        }
    }

    internal let imageView = UIImageView()

    override public func commonInit() {
        imageView.accessibilityIdentifier = "qr code"
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(imageView)
        update()
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
