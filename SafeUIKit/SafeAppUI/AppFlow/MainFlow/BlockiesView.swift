//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

@IBDesignable
class BlockiesView: UIImageView {

    @IBInspectable
    var seed: String = "String" {
        didSet {
            updateImage()
        }
    }

    convenience init(seed: String) {
        self.init(frame: CGRect.zero)
        self.seed = seed
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override init(image: UIImage?) {
        super.init(image: image)
        commonInit()
    }

    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        makeCircleBounds()
        updateImage()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateImage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        makeCircleBounds()
    }

    private func updateImage() {
        image = UIImage.create(seed: seed)
    }

    private func makeCircleBounds() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        clipsToBounds = true
    }

}
