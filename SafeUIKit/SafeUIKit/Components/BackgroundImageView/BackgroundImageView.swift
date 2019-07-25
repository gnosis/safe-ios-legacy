//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public final class BackgroundImageView: UIImageView {

    private var dimmedView: UIView!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        backgroundColor = ColorName.snowwhite.color
        image = Asset.backgroundDarkImage.image
        dimmedView = UIView()
        dimmedView.backgroundColor = ColorName.transparent.color
        dimmedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmedView.frame = frame
        insertSubview(dimmedView, at: 0)
    }

    public var isDimmed = false {
        didSet {
            dimmedView.backgroundColor = isDimmed ?
                ColorName.black.color.withAlphaComponent(0.15) :
                ColorName.transparent.color
        }
    }

    public var isWhite = false {
        didSet {
            if isWhite {
                image = nil
            } else {
                image = Asset.backgroundDarkImage.image
            }
        }
    }

}
