//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public final class H1Label: UILabel {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    private func configure() {
        font = UIFont.systemFont(ofSize: 36)
        numberOfLines = 0
        textColor = .black
    }

}
