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
        let format = LocalizedString("app_version", comment: "App Version")
        var appVersion = "unknown"
        if let version = SystemInfo.marketingVersion, let build = SystemInfo.buildNumber,
            let label = SystemInfo.bundleLabel {
            appVersion = "\(version) (\(build)) \(label)"
        }
        appVersionLabel.text = String(format: format, appVersion)
    }

}
