//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class SelectedSafeTableViewCell: SafeTableViewCell {

    override func configure(safe: SettingsTableViewController.SafeDescription) {
        super.configure(safe: safe)
        backgroundView?.backgroundColor = .white
    }

}
