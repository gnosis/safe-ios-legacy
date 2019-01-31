//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class FeeCalculationErrorLine: FeeCalculationLine {

    var text: String
    var textStyle = ErrorTextStyle()

    init(text: String) {
        self.text = text
    }

    override func makeView() -> UIView {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: text, style: textStyle)
        label.numberOfLines = 0
        return label
    }

    class ErrorTextStyle: AttributedStringStyle {

        override var fontColor: UIColor { return ColorName.tomato.color }
        override var fontSize: Double { return 14 }

    }

    override func equals(to rhs: FeeCalculationLine) -> Bool {
        guard let rhs = rhs as? FeeCalculationErrorLine else { return false }
        return text == rhs.text
    }

}
