//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class RateAppCommand: MenuCommand {

    override var title: String {
        return LocalizedString("rate_app", comment: "Rate App").capitalized
    }

    override func run() {
        SupportFlowCoordinator(from: MainFlowCoordinator.shared).openRateApp()
    }

}
