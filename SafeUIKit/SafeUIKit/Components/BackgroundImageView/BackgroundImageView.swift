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
        image = Asset.backgroundImage.image
        dimmedView = UIView()
        dimmedView.backgroundColor = .clear
        dimmedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmedView.frame = frame
        addSubview(dimmedView)
    }

    public var isDimmed = false {
        didSet {
            dimmedView.backgroundColor = isDimmed ? UIColor.black.withAlphaComponent(0.1) : .clear
        }
    }

}
