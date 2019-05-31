//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public final class TransferView: BaseCustomView {

    @IBOutlet weak var fromIdenticonView: IdenticonView!
    @IBOutlet weak var toIdenticonView: IdenticonView!
    @IBOutlet weak var fromAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var toAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var amountLabel: AmountLabel!
    @IBOutlet weak var balanceLabel: AmountLabel!

    public var fromAddress: String! {
        didSet {
            update()
        }
    }
    public var toAddress: String! {
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

    public override func commonInit() {
        safeUIKit_loadFromNib(forClass: TransferView.self)
        style()
        update()
    }

    private func style() {
        fromAddressLabel.textColor = ColorName.darkSlateBlue.color
        fromAddressLabel.hasFullAddressTooltip = true
        toAddressLabel.textColor = ColorName.darkSlateBlue.color
        toAddressLabel.hasFullAddressTooltip = true
        balanceLabel.textColor = ColorName.darkSlateBlue.color
        balanceLabel.isShowingPlusSign = false
        amountLabel.textColor = ColorName.darkSlateBlue.color
        amountLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    }

    public override func update() {
        fromIdenticonView.seed = fromAddress ?? ""
        fromAddressLabel.address = fromAddress
        toIdenticonView.seed = toAddress ?? ""
        toAddressLabel.address = toAddress
        amountLabel.amount = tokenData
        balanceLabel.amount = balanceData
    }

    public func setFailed() {
        amountLabel.textColor = ColorName.lightGreyBlue.color
    }

    public func setIncoming() {
        amountLabel.textColor = ColorName.greenTeal.color
    }
}
