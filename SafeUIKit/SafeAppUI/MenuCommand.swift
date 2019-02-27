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

    var childFlowCoordinator: FlowCoordinator!

    func run(mainFlowCoordinator: MainFlowCoordinator) {
        mainFlowCoordinator.saveCheckpoint()
        mainFlowCoordinator.enter(flow: childFlowCoordinator) { [unowned mainFlowCoordinator] in
            DispatchQueue.main.async {
                mainFlowCoordinator.popToLastCheckpoint()
                mainFlowCoordinator.pop()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                    mainFlowCoordinator.showTransactionList()
                }
            }
        }
    }

}
