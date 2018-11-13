//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public final class TransferView: UIView {

    public var fromAddress: String! {
        didSet {
            guard fromAddress != nil else { return }
            fromIdenticonView.seed = fromAddress
            fromAddressLabel.text = fromAddress
        }
    }
    public var toAddress: String! {
        didSet {
            guard toAddress != nil else { return }
            toIdenticonView.seed = toAddress
            toAddressLabel.text = toAddress
        }
    }
    public var tokenData: TokenData! {
        didSet {
            // TODO
        }
    }

    @IBOutlet weak var fromIdenticonView: IdenticonView!
    @IBOutlet weak var toIdenticonView: IdenticonView!

    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!

    @IBOutlet weak var amountLabel: UILabel!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        safeUIKit_loadFromNib(forClass: TransferView.self)
        fromIdenticonView.seed = ""
        fromAddressLabel.text = ""
        toIdenticonView.seed = ""
        toAddressLabel.text = ""
    }

}
