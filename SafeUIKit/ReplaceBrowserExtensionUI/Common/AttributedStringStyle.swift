//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

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
        style.firstLineHeadIndent = CGFloat(firstLineHeadIndent)
        style.headIndent = CGFloat(nonFirstLinesHeadIndent)
        style.tailIndent = CGFloat(allLinesTailIndent)
        style.minimumLineHeight = CGFloat(minimumLineHeight)
        style.maximumLineHeight = CGFloat(maximumLineHeight)
        style.lineHeightMultiple = CGFloat(lineHeightMultiplier)
        style.lineSpacing = CGFloat(lineSpacing)
        style.lineBreakMode = lineBreakMode
        return style
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
