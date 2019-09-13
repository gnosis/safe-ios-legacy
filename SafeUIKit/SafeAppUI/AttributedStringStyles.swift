//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import SafeUIKit

class HeaderStyle: AttributedStringStyle {

    override var fontSize: Double { return 17 }
    override var fontWeight: UIFont.Weight { return .semibold }
    override var fontColor: UIColor { return ColorName.darkBlue.color }
    override var alignment: NSTextAlignment { return .center }
    override var minimumLineHeight: Double { return 22 }
    override var maximumLineHeight: Double { return 22 }

}

class DescriptionStyle: AttributedStringStyle {

    override var fontSize: Double { return 17 }
    override var fontWeight: UIFont.Weight { return .regular }
    override var fontColor: UIColor { return ColorName.darkGrey.color }
    override var alignment: NSTextAlignment { return .center }
    override var minimumLineHeight: Double { return 22 }
    override var maximumLineHeight: Double { return 22 }
    override var spacingAfterParagraph: Double { return 12 }

}
