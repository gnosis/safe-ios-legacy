//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

extension RBEIntroViewController {
    
    class LoadingState: CancellableState {

        override func didEnter(controller: RBEIntroViewController) {
            controller.startIndicateLoading()
            controller.showStart()
            controller.disableStart()
//            controller.showBack()
            controller.feeCalculation = EthFeeCalculation()
        }

        override func handleError(_ error: Error, controller: RBEIntroViewController) {
            controller.transition(to: InvalidState(error: error))
        }

        override func didLoad(controller: RBEIntroViewController) {
            controller.transition(to: ReadyState())
        }

    }

}
