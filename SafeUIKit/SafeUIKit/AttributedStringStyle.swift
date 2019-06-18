//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

open class AttributedStringStyle {

    public init() {}

    open var fontSize: Double {
        return 12
    }

    open var fontWeight: UIFont.Weight {
        return .regular
    }

    open var fontColor: UIColor {
        return .black
    }

    open var alignment: NSTextAlignment {
        return .left
    }

    open var spacingAfterParagraph: Double {
        return 0
    }

    open var spacingBeforeParagraph: Double {
        return 0
    }

    open var firstLineHeadIndent: Double {
        return 0
    }

    open var nonFirstLinesHeadIndent: Double {
        return 0
    }

    open var allLinesTailIndent: Double {
        return 0
    }

    open var minimumLineHeight: Double {
        return 0
    }

    open var maximumLineHeight: Double {
        return 0
    }

    open var lineHeightMultiplier: Double {
        return 0
    }

    open var lineSpacing: Double {
        return 0
    }

    open var lineBreakMode: NSLineBreakMode {
        return .byWordWrapping
    }

    open var letterSpacing: Double {
        return 0
    }

    open var underlineStyle: NSUnderlineStyle {
        return NSUnderlineStyle(rawValue: 0)
    }

    open var paragraphStyle: NSParagraphStyle {
        precondition(spacingAfterParagraph >= 0)
        precondition(spacingBeforeParagraph >= 0)
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.paragraphSpacing = CGFloat(spacingAfterParagraph)
        style.paragraphSpacingBefore = CGFloat(spacingBeforeParagraph)
        setUpIndents(in: style)
        setUpLineStyle(in: style)
        return style
    }

    private func setUpLineStyle(in paragraph: NSMutableParagraphStyle) {
        paragraph.minimumLineHeight = CGFloat(minimumLineHeight)
        paragraph.maximumLineHeight = CGFloat(maximumLineHeight)
        paragraph.lineHeightMultiple = CGFloat(lineHeightMultiplier)
        paragraph.lineSpacing = CGFloat(lineSpacing)
        paragraph.lineBreakMode = lineBreakMode
    }

    private func setUpIndents(in paragraph: NSMutableParagraphStyle) {
        paragraph.firstLineHeadIndent = CGFloat(firstLineHeadIndent)
        paragraph.headIndent = CGFloat(nonFirstLinesHeadIndent)
        paragraph.tailIndent = CGFloat(allLinesTailIndent)
    }

    open var font: UIFont {
        return .systemFont(ofSize: CGFloat(fontSize), weight: fontWeight)
    }

}

public extension NSAttributedString {

    convenience init?(string: String?, style: AttributedStringStyle) {
        guard let string = string else { return nil }
        self.init(string: string, style: style)
    }

    convenience init(string: String, style: AttributedStringStyle) {
        self.init(string: string, attributes: [.font: style.font,
                                               .foregroundColor: style.fontColor,
                                               .paragraphStyle: style.paragraphStyle,
                                               .kern: NSNumber(value: style.letterSpacing),
                                               .underlineStyle: NSNumber(value: style.underlineStyle.rawValue)])
    }

}
