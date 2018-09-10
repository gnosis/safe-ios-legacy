//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public final class BackgroundImageView: UIImageView {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    private func configure() {
        image = Asset.backgroundImage.image
    }

}
