//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

// TODO: delete and use IdenticonView
class BlockiesView: DesignableView {

    @IBInspectable
    var seed: String = "String" {
        didSet {
            setNeedsUpdate()
        }
    }

    var imageView: UIImageView!

    override func commonInit() {
        imageView = UIImageView()
        imageView.frame = self.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        didLoad()
    }

    override func update() {
        imageView.image = UIImage.createBlockiesImage(seed: seed)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        makeCircleBounds()
    }

    private func makeCircleBounds() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        clipsToBounds = true
    }

}
