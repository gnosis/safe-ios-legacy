//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class GetInTouchCommand: MenuCommand {

    var supportCoordinator: SupportFlowCoordinator!

    override var title: String {
        return LocalizedString("get_in_touch", comment: "Get In Touch").capitalized
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        supportCoordinator = SupportFlowCoordinator(from: mainFlowCoordinator)
        mainFlowCoordinator.push(GetInTouchTableViewController(delegate: self))
    }

}

extension GetInTouchCommand: GetInTouchTableViewControllerDelegate {

    func openTelegram() {
        supportCoordinator.openTelegram()
    }

    func openMail() {
        supportCoordinator.openMail()
    }

    func openGitter() {
        supportCoordinator.openGitter()
    }

}
