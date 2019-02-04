//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit

extension RBEIntroViewController {

    class State {

        func didEnter(controller: RBEIntroViewController) {}
        func handleError(_ error: Error, controller: RBEIntroViewController) {}
        func back(controller: RBEIntroViewController) {}
        func didLoad(controller: RBEIntroViewController) {}
        func start(controller: RBEIntroViewController) {}
        func didStart(controller: RBEIntroViewController) {}
        func retry(controller: RBEIntroViewController) {}

    }

    class CancellableState: State {

        override func back(controller: RBEIntroViewController) {
            controller.transition(to: CancellingState())
        }

    }

    class BaseErrorState: CancellableState {

        var error: Error

        init(error: Error) {
            self.error = error
        }

        override func retry(controller: RBEIntroViewController) {
            controller.transition(to: LoadingState())
        }

    }

}
