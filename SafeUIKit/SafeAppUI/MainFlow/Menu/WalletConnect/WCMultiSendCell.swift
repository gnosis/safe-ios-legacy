//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class WCMultiSendCell: UITableViewCell {

    @IBOutlet weak var viewButton: StandardButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewButton.style = .plain
    }

    func configure(title: String, target: Any?, action: Selector) {
        viewButton.setTitle(title, for: .normal)
        viewButton.removeTarget(nil, action: nil, for: .touchUpInside)
        viewButton.addTarget(target, action: action, for: .touchUpInside)
    }

}
