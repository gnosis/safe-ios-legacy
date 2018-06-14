//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

class TransactionParticipantView: DesignableView {

    @IBInspectable
    var name: String = "Name" {
        didSet {
            setNeedsUpdate()
        }
    }
    @IBInspectable
    var address: String = "Address" {
        didSet {
            setNeedsUpdate()
        }
    }
    @IBInspectable
    var text: String? {
        didSet {
            setNeedsUpdate()
        }
    }

    var nameLabel: UILabel!
    var addressLabel: UILabel!
    var blockiesView: BlockiesView!
    var textLabel: UILabel!
    var nonTextStack: UIStackView!

    override func commonInit() {
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
        didLoad()
    }


    override func update() {
        textLabel.isHidden = text == nil
        textLabel.text = text

        nonTextStack.isHidden = text != nil
        nameLabel.text = name
        addressLabel.text = address
        blockiesView.seed = address
    }


}
