//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class PrivacyPolicyCommand: MenuCommand {

    override var title: String {
        return LocalizedString("privacy_policy", comment: "Privacy policy menu item").capitalized
    }

    override func run() {
        SupportFlowCoordinator(from: MainFlowCoordinator.shared).openPrivacyPolicy()
    }

}
