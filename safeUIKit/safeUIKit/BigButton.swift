//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

@IBDesignable
public final class BigButton: UIButton {

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

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }

    private func configure() {
        titleLabel?.font = UIFont.systemFont(ofSize: 26)
    }

}
