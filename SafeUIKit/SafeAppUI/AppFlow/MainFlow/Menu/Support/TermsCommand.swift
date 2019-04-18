//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class TermsCommand: MenuCommand {

    override var title: String {
        return LocalizedString("terms_of_service", comment: "Terms menu item").capitalized
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        SupportFlowCoordinator(from: mainFlowCoordinator).openTermsOfUse()
    }

}
