//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class SafeLabelTitleView: BaseCustomLabel {

    override public func commonInit() {
        text = "SAFE"
        font = UIFont(descriptor: UIFontDescriptor(name: "Montserrat-Bold", size: 17), size: 17)
        textColor = ColorName.dusk.color
        textAlignment = .center
    }

}
