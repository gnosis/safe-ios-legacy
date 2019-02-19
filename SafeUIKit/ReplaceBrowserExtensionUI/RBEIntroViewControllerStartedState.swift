//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

extension RBEIntroViewController {

    class StartedState: State {

        override func didEnter(controller: RBEIntroViewController) {
            controller.stopIndicateLoading()
            controller.enableStart()
            controller.showStart()
            controller.delegate?.rbeIntroViewControllerDidStart()
        }

        override func start(controller: RBEIntroViewController) {
            controller.transition(to: StartingState())
        }
    
    }

}
