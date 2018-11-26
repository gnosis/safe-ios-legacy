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
    public var tokenData: TokenData! {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        safeUIKit_loadFromNib(forClass: TransferView.self)
        update()
    }

    public override func update() {
        fromIdenticonView.seed = fromAddress ?? ""
        fromAddressLabel.address = fromAddress
        toIdenticonView.seed = toAddress ?? ""
        toAddressLabel.address = toAddress
        amountLabel.amount = tokenData
    }

}
