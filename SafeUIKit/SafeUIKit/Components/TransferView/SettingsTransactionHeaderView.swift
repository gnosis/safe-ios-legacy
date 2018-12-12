//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class SettingsTransactionHeaderView: BaseCustomView {

    @IBOutlet weak var fromIdenticonView: IdenticonView!
    @IBOutlet weak var fromAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    public var fromAddress: String? {
        didSet {
            update()
        }
    }

    public var titleText: String? {
        didSet {
            update()
        }
    }

    public var detailText: String? {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        safeUIKit_loadFromNib(forClass: SettingsTransactionHeaderView.self)
        update()
    }

    public override func update() {
        fromIdenticonView.seed = fromAddress ?? ""
        fromAddressLabel.address = fromAddress
        titleLabel.text = titleText
        detailLabel.text = detailText
    }

}
