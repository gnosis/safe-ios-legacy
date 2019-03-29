//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class TransactionParticipantView: BaseCustomView {

    var name: String = "Name" {
        didSet {
            update()
        }
    }
    var address: String = "Address" {
        didSet {
            update()
        }
    }
    var text: String? {
        didSet {
            update()
        }
    }

    var nameLabel: UILabel!
    var addressLabel: UILabel!
    var identiconView: IdenticonView!
    var textLabel: UILabel!
    var nonTextStack: UIStackView!

    override func commonInit() {
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        nameLabel.textColor = ColorName.darkSlateBlue.color

        addressLabel = UILabel()
        addressLabel.font = UIFont.systemFont(ofSize: 13)
        addressLabel.textColor = ColorName.lightGreyBlue.color
        addressLabel.lineBreakMode = .byTruncatingMiddle

        identiconView = IdenticonView()
        identiconView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, addressLabel])
        nameStack.axis = .vertical

        nonTextStack = UIStackView(arrangedSubviews: [identiconView, nameStack])
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
                identiconView.widthAnchor.constraint(equalToConstant: 32),
                identiconView.heightAnchor.constraint(equalToConstant: 32)
            ])
        update()
    }


    override func update() {
        textLabel.isHidden = text == nil
        textLabel.text = text

        nonTextStack.isHidden = text != nil
        nameLabel.text = name
        addressLabel.text = address
        identiconView.seed = address
    }


}
