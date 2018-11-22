//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public final class TransferView: BaseCustomView {

    @IBOutlet weak var fromIdenticonView: IdenticonView!
    @IBOutlet weak var toIdenticonView: IdenticonView!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

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
        fromAddressLabel.text = fromAddress
        toIdenticonView.seed = toAddress ?? ""
        toAddressLabel.text = toAddress
        if let data = tokenData, let balance = tokenData.balance {
            let tokenFormatter = TokenNumberFormatter.ERC20Token(code: data.code,
                                                                 decimals: data.decimals,
                                                                 displayedDecimals: 4)
            amountLabel.text = tokenFormatter.string(from: -balance)
        } else {
            amountLabel.text = nil
        }
    }

}
