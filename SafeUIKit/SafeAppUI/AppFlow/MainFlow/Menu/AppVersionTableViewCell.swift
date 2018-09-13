//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class AppVersionTableViewCell: UITableViewCell {

    static let height: CGFloat = 32

    @IBOutlet weak var appVersionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        appVersionLabel.text = LocalizedString("menu.app_version", comment: "App Version") + " " + appVersion
    }

}
