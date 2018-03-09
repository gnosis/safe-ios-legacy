//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

class H1Label: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        font = UIFont.systemFont(ofSize: 36)
        numberOfLines = 0
        textColor = ColorName.black.color
    }

}
