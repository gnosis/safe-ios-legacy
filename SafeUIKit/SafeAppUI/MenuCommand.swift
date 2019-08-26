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

    func run(mainFlowCoordinator: MainFlowCoordinator) {
        mainFlowCoordinator.saveCheckpoint()
        mainFlowCoordinator.enter(flow: childFlowCoordinator) { [unowned mainFlowCoordinator] in
            DispatchQueue.main.async {
                mainFlowCoordinator.popToLastCheckpoint()
                self.didExitToMenu(mainFlowCoordinator: mainFlowCoordinator)
            }
        }
    }

    func didExitToMenu(mainFlowCoordinator: MainFlowCoordinator) {
        mainFlowCoordinator.pop()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
            mainFlowCoordinator.showTransactionList()
        }
    }

}
