//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public protocol TransferViewDelegate: class {
    func transferView(_ view: TransferView, didSelectActionForAddress address: String)
}

public final class TransferView: BaseCustomView {

    @IBOutlet weak var fromIdenticonView: IdenticonView!
    @IBOutlet weak var toIdenticonView: IdenticonView!
    @IBOutlet weak var fromAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var toAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var amountLabel: AmountLabel!
    @IBOutlet weak var balanceLabel: AmountLabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var fromThreeDotsButton: UIButton!
    @IBOutlet weak var toThreeDotsButton: UIButton!

    public weak var delegate: TransferViewDelegate?

    public var fromAddress: String! {
        didSet {
            update()
        }
    }

    public var fromAddressName: String? {
        didSet {
            update()
        }
    }

    public var toAddress: String! {
        didSet {
            update()
        }
    }

    public var toAddressName: String? {
        didSet {
            update()
        }
    }

    public var balanceData: TokenData! {
        didSet {
            update()
        }
    }

    public var tokenData: TokenData! {
        didSet {
            update()
        }
    }

    public var showFromAddressActions: Bool = false {
        didSet {
            update()
        }
    }

    public var showToAddressActions: Bool = false {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        safeUIKit_loadFromNib(forClass: TransferView.self)
        style()
        update()
    }

    private func style() {
        separatorView.backgroundColor = ColorName.whitesmoke.color
        fromAddressLabel.textColor = ColorName.darkBlue.color
        fromAddressLabel.hasFullAddressTooltip = true
        toAddressLabel.textColor = ColorName.darkBlue.color
        toAddressLabel.hasFullAddressTooltip = true
        balanceLabel.textColor = ColorName.darkBlue.color
        balanceLabel.isShowingPlusSign = false
        balanceLabel.hasTooltip = true
        amountLabel.textColor = ColorName.darkGrey.color
        amountLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        amountLabel.hasTooltip = true
    }

    public override func update() {
        fromIdenticonView.seed = fromAddress ?? ""
        fromAddressLabel.address = fromAddress
        fromAddressLabel.name = fromAddressName
        toIdenticonView.seed = toAddress ?? ""
        toAddressLabel.address = toAddress
        toAddressLabel.name = toAddressName
        amountLabel.amount = tokenData
        balanceLabel.amount = balanceData
        fromThreeDotsButton.isHidden = !showFromAddressActions
        toThreeDotsButton.isHidden = !showToAddressActions
    }

    public func setFailed() {
        amountLabel.textColor = ColorName.mediumGrey.color
    }

    public func setIncoming() {
        amountLabel.textColor = ColorName.hold.color
    }

    public func setSmallerAmountLabelFontSize() {
        amountLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    }

    @IBAction func selectFromAddressAction(_ sender: Any) {
        delegate?.transferView(self, didSelectActionForAddress: fromAddress)
    }

    @IBAction func selectToAddressAction(_ sender: Any) {
        delegate?.transferView(self, didSelectActionForAddress: toAddress)
    }

}
