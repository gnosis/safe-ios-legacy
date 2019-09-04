//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class FeeCalculationErrorLine: FeeCalculationLine {

    public var text: String
    var textStyle = ErrorTextStyle()
    public var iconEnabled: Bool = false

    public init(text: String) {
        self.text = text
    }

    public func set(error: Error?) {
        text = error?.localizedDescription ?? ""
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

    func makeErrorIcon() -> UIView {
        let image = UIImageView(image: UIImage(named: "error",
                                               in: Bundle(for: FeeCalculationLine.self),
                                               compatibleWith: nil))
        image.contentMode = .top
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 18),
            image.widthAnchor.constraint(equalToConstant: 16)])
        return image
    }

    class ErrorTextStyle: AttributedStringStyle {

        override var fontColor: UIColor { return ColorName.tomato.color }
        override var fontSize: Double { return 14 }

    }

    override func equals(to rhs: FeeCalculationLine) -> Bool {
        guard let rhs = rhs as? FeeCalculationErrorLine else { return false }
        return text == rhs.text
    }

    public func enableIcon() -> FeeCalculationErrorLine {
        iconEnabled = true
        return self
    }

}
