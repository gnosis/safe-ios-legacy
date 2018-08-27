//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var menuIconImageView: UIImageView!

    func configure(menuItem: MenuTableViewController.MenuItem) {
        itemNameLabel.text = menuItem.name
        menuIconImageView.image = menuItem.icon
    }

}
