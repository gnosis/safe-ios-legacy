//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class GetInTouchCommand: MenuCommand {

    override var title: String {
        return LocalizedString("get_in_touch", comment: "Get In Touch").capitalized
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        mainFlowCoordinator.push(GetInTouchTableViewController())
    }

}
