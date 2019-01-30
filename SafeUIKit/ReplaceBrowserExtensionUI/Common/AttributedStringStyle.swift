//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

class AttributedStringStyle {

    var fontSize: Double {
        return 12
    }

    var fontWeight: UIFont.Weight {
        return .regular
    }

    var fontColor: UIColor {
        return .black
    }

    var alignment: NSTextAlignment {
        return .left
    }

    var spacingAfterParagraph: Double {
        return 0
    }

    var spacingBeforeParagraph: Double {
        return 0
    }

    var firstLineHeadIndent: Double {
        return 0
    }

    var nonFirstLinesHeadIndent: Double {
        return 0
    }

    var allLinesTailIndent: Double {
        return 0
    }

    var minimumLineHeight: Double {
        return 0
    }

    var maximumLineHeight: Double {
        return 0
    }

    var lineHeightMultiplier: Double {
        return 0
    }

    var lineSpacing: Double {
        return 0
    }

    var lineBreakMode: NSLineBreakMode {
        return .byWordWrapping
    }

    var letterSpacing: Double {
        return 0
    }

    var paragraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.paragraphSpacing = CGFloat(spacingAfterParagraph)
        style.paragraphSpacingBefore = CGFloat(spacingBeforeParagraph)
        setUpLineStyle(in: style)
        return style
    }

    private func setUpLineStyle(in paragraph: NSMutableParagraphStyle) {
        paragraph.firstLineHeadIndent = CGFloat(firstLineHeadIndent)
        paragraph.headIndent = CGFloat(nonFirstLinesHeadIndent)
        paragraph.tailIndent = CGFloat(allLinesTailIndent)
        paragraph.minimumLineHeight = CGFloat(minimumLineHeight)
        paragraph.maximumLineHeight = CGFloat(maximumLineHeight)
        paragraph.lineHeightMultiple = CGFloat(lineHeightMultiplier)
        paragraph.lineSpacing = CGFloat(lineSpacing)
        paragraph.lineBreakMode = lineBreakMode
    }

    var font: UIFont {
        return .systemFont(ofSize: CGFloat(fontSize), weight: fontWeight)
    }

}

extension NSAttributedString {

    convenience init(string: String, style: AttributedStringStyle) {
        self.init(string: string, attributes: [.font: style.font,
                                               .foregroundColor: style.fontColor,
                                               .paragraphStyle: style.paragraphStyle,
                                               .kern: NSNumber(value: style.letterSpacing)])
    }

}
