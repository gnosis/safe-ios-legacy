//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import SafeUIKit

public class FeeCalculationErrorLine: FeeCalculationLine {

    var text: String
    var textStyle = ErrorTextStyle()
    var iconEnabled: Bool = false

    init(text: String) {
        self.text = text
    }

    override func makeView() -> UIView {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: text, style: textStyle)
        label.numberOfLines = 0
        if iconEnabled {
            let icon = makeErrorIcon()
            let stack = UIStackView(arrangedSubviews: [icon, label])
            stack.spacing = 8
            return stack
        }
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

    func enableIcon() -> FeeCalculationErrorLine {
        iconEnabled = true
        return self
    }

}
