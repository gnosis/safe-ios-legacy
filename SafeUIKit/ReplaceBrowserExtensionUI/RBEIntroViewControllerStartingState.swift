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
            controller.startIndicateLoading()
            controller.showStart()
            controller.disableStart()
            doStart(controller: controller)
        }

        func doStart(controller: RBEIntroViewController) {
            asyncInBackground {
                guard let transaction = controller.transactionID else { return }
                do {
                    try controller.starter?.start(transaction: transaction)
                    DispatchQueue.main.sync {
                        controller.didStart()
                    }
                } catch let error {
                    DispatchQueue.main.sync {
                        controller.handleError(error)
                    }
                }
            }
        }
    }

}
