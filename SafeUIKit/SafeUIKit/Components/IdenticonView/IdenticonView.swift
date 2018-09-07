//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class IdenticonView: DesignableView {

    @IBInspectable
    public var displayShadow: Bool = false {
        didSet {
            layer.shadowOpacity = displayShadow ? shadowOpacity : 0
        }
    }

    @IBInspectable
    public var seed: String = "Identicon" {
        didSet {
            setNeedsUpdate()
        }
    }

    private let imageView = UIImageView()

    private let shadowOpacity: Float = 0.8
    private let shadowOffset = CGSize(width: 0, height: 2)
    private let shadowColor = UIColor.black

    override public func commonInit() {
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(imageView)

        imageView.layer.cornerRadius = bounds.width / 2
        imageView.clipsToBounds = true

        backgroundColor = .clear
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 100).cgPath
        displayShadow = false
        didLoad()
    }

    override public func update() {
        imageView.image = UIImage.createBlockiesImage(seed: seed)
    }

}
