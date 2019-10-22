//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

class MenuCommand {

    var title: String {
        preconditionFailure("Override this method")
    }

    var isHidden: Bool {
        return false
    }

    var hasDisclosure: Bool {
        return true
    }

    var height: CGFloat {
        return UITableView.automaticDimension
    }

    var childFlowCoordinator: FlowCoordinator!

    func run() {
        MainFlowCoordinator.shared.saveCheckpoint()
        MainFlowCoordinator.shared.enter(flow: childFlowCoordinator) { [unowned self] in
            DispatchQueue.main.async {
                MainFlowCoordinator.shared.popToLastCheckpoint()
                self.didExitToMenu()
            }
        }
    }

    func didExitToMenu() {
        MainFlowCoordinator.shared.pop()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
            MainFlowCoordinator.shared.showTransactionList()
        }
    }

}
