//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

final class PlaceholderCreator {

    func create(size: CGSize,
                cornerRadius: CGFloat,
                text: String,
                font: UIFont,
                textColor: UIColor,
                backgroundColor: UIColor) -> UIImage? {
        return UIGraphicsImageRenderer(size: size).image { _ in
            let rect = CGRect(origin: .zero, size: size)

            backgroundColor.setFill()
            let shape = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            shape.fill()

            textColor.setFill()
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let textAttributes = [NSAttributedString.Key.font: font,
                                  NSAttributedString.Key.paragraphStyle: paragraph]
            let textRectAtVerticalCenter = rect.offsetBy(dx: 0, dy: (rect.height - font.lineHeight) / 2)
            (text as NSString).draw(in: textRectAtVerticalCenter, withAttributes: textAttributes)
        }
    }

}
