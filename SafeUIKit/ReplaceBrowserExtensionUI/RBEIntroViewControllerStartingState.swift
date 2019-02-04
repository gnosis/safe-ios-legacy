//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

extension RBEIntroViewController {

    class StartingState: State {

        override func didStart(controller: RBEIntroViewController) {
            controller.transition(to: StartedState())
        }

        override func handleError(_ error: Error, controller: RBEIntroViewController) {
            controller.transition(to: ErrorState(error: error))
        }

        override func didEnter(controller: RBEIntroViewController) {
            controller.navigationItem.titleView = LoadingTitleView()
            controller.navigationItem.rightBarButtonItems = [controller.startButtonItem]
            controller.startButtonItem.isEnabled = false
        }
    }

}
