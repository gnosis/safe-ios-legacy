//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

extension RBEIntroViewController {

    class ReadyState: CancellableState {

        override func start(controller: RBEIntroViewController) {
            controller.transition(to: StartingState())
        }

        override func didEnter(controller: RBEIntroViewController) {
            controller.reloadData()
            controller.feeCalculationView.update()
            controller.navigationItem.titleView = nil
            controller.startButtonItem.isEnabled = true
        }

    }

}
