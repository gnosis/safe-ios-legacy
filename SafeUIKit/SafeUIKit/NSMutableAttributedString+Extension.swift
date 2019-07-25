//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public extension NSMutableAttributedString {

    func addLinkIcon() {
        let textAttachment = NSTextAttachment()
        textAttachment.image = Asset.shareLink.image
        let textAttachmentStr = NSAttributedString(attachment: textAttachment)
        let iconAttrStr = NSMutableAttributedString(string: " ")
        iconAttrStr.append(textAttachmentStr)
        let iconRange = NSRange(location: 0, length: iconAttrStr.length)
        iconAttrStr.addAttribute(.foregroundColor, value: ColorName.hold.color, range: iconRange)
        append(iconAttrStr)
    }

}
