//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

final class ContractUpgradeHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var updateButton: StandardButton!

    var onUpgrade: (() -> Void)?

    enum Strings {
        static let title = LocalizedString("contract_upgrade_available", comment: "Contract upgrade available")
        static let description = LocalizedString("in_the_new_version_we_added_support_of_erc1155",
                                                 comment: "Upgrade description")
        static let upgradeNow = LocalizedString("upgrade_now", comment: "Upgrade now")
    }

    @IBAction func update(_ sender: Any) {
        onUpgrade?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = Strings.title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = ColorName.darkBlue.color
        descriptionLabel.attributedText = NSAttributedString(string: Strings.description, style: DescriptionStyle())
        descriptionLabel.font = UIFont.systemFont(ofSize: 17)
        descriptionLabel.textColor = ColorName.darkGrey.color
        updateButton.style = .plain
        updateButton.setTitle(Strings.upgradeNow, for: .normal)
    }

}
