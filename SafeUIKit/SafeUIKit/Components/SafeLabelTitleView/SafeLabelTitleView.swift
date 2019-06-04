//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class SafeLabelTitleView: BaseCustomLabel {

    override public func commonInit() {
        type(of: self).apply(to: self)
    }

    public static func apply(to label: UILabel) {
        label.text = "SAFE"
        label.font = UIFont(descriptor: UIFontDescriptor(name: "Montserrat-Bold", size: 17), size: 17)
        label.textColor = ColorName.dusk.color
        label.textAlignment = .center
    }

}
