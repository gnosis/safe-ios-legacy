//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class HorizontalSeparatorView: UIView {

    @IBInspectable
    var size: CGFloat = 1 {
        didSet {
            update()
        }
    }
    var heightConstraint: NSLayoutConstraint!
    var isLoaded = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        update()
    }

    func commonInit() {
        heightConstraint = heightAnchor.constraint(equalToConstant: 1)
        NSLayoutConstraint.activate(
            [
                heightConstraint
            ])
        isLoaded = true
        update()
    }

    func update() {
        guard isLoaded else { return }
        backgroundColor = ColorName.paleGreyFour.color
        heightConstraint.constant = size
        setNeedsDisplay()
    }

}

@IBDesignable
class TransactionValueView: UIView {

    @IBInspectable
    var tokenAmount: String = "+9.11300 ETH" {
        didSet {
            update()
        }
    }
    @IBInspectable
    var fiatAmount: String = "≈ $643.42" {
        didSet {
            update()
        }
    }
    @IBInspectable
    var IBStyle: Int {
        get { return style.rawValue }
        set {
            setStyle(newValue)
        }
    }
    @IBInspectable
    var  isSingleValue: Bool = false {
        didSet {
            update()
        }
    }
    var style: TransactionValueStyle = .positive {
        didSet {
            update()
        }
    }

    var tokenLabel: UILabel!
    var fiatLabel: UILabel!
    private var isLoaded = false

    struct Colors {
        static let neutral = ColorName.darkSlateBlue.color
        static let positive = ColorName.greenTeal.color
        static let negative = ColorName.tomato.color

        static let fiat = ColorName.blueyGrey.color
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    func commonInit() {
        tokenLabel = UILabel()
        tokenLabel.font = UIFont.systemFont(ofSize: 19)
        tokenLabel.textColor = Colors.neutral
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
        isLoaded = true
        update()
    }

    func setStyle(_ newValue: Int) {
        if let value = TransactionValueStyle(rawValue: newValue) {
            style = value
        } else {
            style = .neutral
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        update()
    }

    func update() {
        guard isLoaded else { return }
        tokenLabel.font = isSingleValue ? UIFont.systemFont(ofSize: 13) : UIFont.systemFont(ofSize: 19)
        tokenLabel.text = tokenAmount
        fiatLabel.isHidden = isSingleValue
        fiatLabel.text = fiatAmount
        updateStyle()
    }

    func updateStyle() {
        switch style {
        case .neutral: tokenLabel.textColor = Colors.neutral
        case .negative: tokenLabel.textColor = Colors.negative
        case .positive: tokenLabel.textColor = Colors.positive
        }
    }

}

enum TransactionValueStyle: Int {
    case negative = -1
    case neutral
    case positive
}

@IBDesignable
class TransactionParticipantView: UIView {

    @IBInspectable
    var name: String = "Name" {
        didSet {
            update()
        }
    }
    @IBInspectable
    var address: String = "Address" {
        didSet {
            update()
        }
    }
    @IBInspectable
    var text: String? {
        didSet {
            update()
        }
    }

    var nameLabel: UILabel!
    var addressLabel: UILabel!
    var blockiesView: BlockiesView!
    var textLabel: UILabel!
    var nonTextStack: UIStackView!
    private var isLoaded = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        update()
    }

    func commonInit() {
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        nameLabel.textColor = ColorName.darkSlateBlue.color

        addressLabel = UILabel()
        addressLabel.font = UIFont.systemFont(ofSize: 13)
        addressLabel.textColor = ColorName.blueyGrey.color
        addressLabel.lineBreakMode = .byTruncatingMiddle

        blockiesView = BlockiesView(seed: address)
        blockiesView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, addressLabel])
        nameStack.axis = .vertical

        nonTextStack = UIStackView(arrangedSubviews: [blockiesView, nameStack])
        nonTextStack.axis = .horizontal
        nonTextStack.distribution = .fill
        nonTextStack.alignment = .center
        nonTextStack.spacing = 10

        textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 13)
        textLabel.textColor = ColorName.battleshipGrey.color
        textLabel.numberOfLines = 0

        let wholeStack = UIStackView(arrangedSubviews: [textLabel, nonTextStack])
        wholeStack.axis = .horizontal

        wholeStack.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        wholeStack.frame = self.bounds

        addSubview(wholeStack)

        NSLayoutConstraint.activate(
            [
                blockiesView.widthAnchor.constraint(equalToConstant: 32),
                blockiesView.heightAnchor.constraint(equalToConstant: 32)
            ])
        isLoaded = true
        update()
    }


    func update() {
        guard isLoaded else { return }
        textLabel.isHidden = text == nil
        textLabel.text = text

        nonTextStack.isHidden = text != nil
        nameLabel.text = name
        addressLabel.text = address
        blockiesView.seed = address
    }


}

@IBDesignable
class BlockiesView: UIImageView {

    @IBInspectable
    var seed: String = "String" {
        didSet {
            updateImage()
        }
    }

    convenience init(seed: String) {
        self.init(frame: CGRect.zero)
        self.seed = seed
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override init(image: UIImage?) {
        super.init(image: image)
        commonInit()
    }

    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        makeCircleBounds()
        updateImage()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateImage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        makeCircleBounds()
    }

    private func updateImage() {
        image = UIImage.create(seed: seed)
    }

    private func makeCircleBounds() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        clipsToBounds = true
    }

}
