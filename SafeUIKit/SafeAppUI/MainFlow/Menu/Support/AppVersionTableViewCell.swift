//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

final class AppVersionTableViewCell: UITableViewCell {

    static let height: CGFloat = 32

    @IBOutlet weak var appVersionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        appVersionLabel.text = SystemInfo.appVersionText
    }

}
