//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class TransactionValueView: DesignableView {

    @IBInspectable
    var tokenAmount: String = "+9.11300 ETH" {
        didSet {
            setNeedsUpdate()
        }
    }
    @IBInspectable
    var fiatAmount: String = "≈ $643.42" {
        didSet {
            setNeedsUpdate()
        }
    }
    @IBInspectable
    var IBStyle: Int {
        get { return style.rawValue }
        set {
            setNeedsUpdate(newValue)
        }
    }
    @IBInspectable
    var  isSingleValue: Bool = false {
        didSet {
            setNeedsUpdate()
        }
    }
    var style: TransactionValueStyle = .positive {
        didSet {
            setNeedsUpdate()
        }
    }

    func setStyle(_ newValue: Int) {
        if let value = TransactionValueStyle(rawValue: newValue) {
            style = value
        } else {
            style = .neutral
        }
    }

    var tokenLabel: UILabel!
    var fiatLabel: UILabel!

    struct Colors {
        static let fiat = ColorName.blueyGrey.color
    }

    override func commonInit() {
        tokenLabel = UILabel()
        tokenLabel.font = UIFont.systemFont(ofSize: 19)
        tokenLabel.textAlignment = .right
        tokenLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        tokenLabel.adjustsFontSizeToFitWidth = true
        tokenLabel.allowsDefaultTighteningForTruncation = true
        tokenLabel.minimumScaleFactor = 0.4

        fiatLabel = UILabel()
        fiatLabel.font = UIFont.systemFont(ofSize: 13)
        fiatLabel.textColor = Colors.fiat
        fiatLabel.textAlignment = .right

        let labelStack = UIStackView(arrangedSubviews: [tokenLabel, fiatLabel])
        labelStack.axis = .vertical
        labelStack.alignment = .trailing
        labelStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(labelStack)

        NSLayoutConstraint.activate(
            [
                labelStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                labelStack.topAnchor.constraint(equalTo: topAnchor),
                widthAnchor.constraint(equalTo: labelStack.widthAnchor),
                heightAnchor.constraint(equalTo: labelStack.heightAnchor)
            ])
        didLoad()
    }

    override func update() {
        guard isLoaded else { return }
        tokenLabel.font = isSingleValue ? UIFont.systemFont(ofSize: 13) : UIFont.systemFont(ofSize: 19)
        tokenLabel.text = tokenAmount
        fiatLabel.isHidden = isSingleValue
        fiatLabel.text = fiatAmount
        tokenLabel.textColor = style.colorValue
    }

}

enum TransactionValueStyle: Int {
    case negative = -1
    case neutral
    case positive

    struct Colors {
        static let neutral = ColorName.darkSlateBlue.color
        static let positive = ColorName.greenTeal.color
        static let negative = ColorName.tomato.color
    }

    var colorValue: UIColor {
        switch self {
        case .neutral: return Colors.neutral
        case .negative: return Colors.negative
        case .positive: return Colors.positive
        }
    }
}
