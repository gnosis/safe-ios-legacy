//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

extension RBEIntroViewController {

    // MARK: Base States

    class State {

        func didEnter(controller: RBEIntroViewController) {}
        func willPush(controller: RBEIntroViewController, onTopOf topViewController: UIViewController) {}
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

        override func retry(controller: RBEIntroViewController) {
            controller.transition(to: LoadingState())
        }

    }

    // MARK: Controller states

    class LoadingState: CancellableState {

        override func didEnter(controller: RBEIntroViewController) {
            controller.navigationItem.titleView = LoadingTitleView()
            controller.navigationItem.rightBarButtonItems = [controller.startButtonItem]
            controller.startButtonItem.isEnabled = false
            controller.feeCalculationView.calculation = .loading
        }

        override func willPush(controller: RBEIntroViewController, onTopOf topViewController: UIViewController) {
            topViewController.navigationItem.backBarButtonItem = controller.backButtonItem
        }

        override func handleError(_ error: Error, controller: RBEIntroViewController) {
            controller.transition(to: InvalidState())
        }

        override func didLoad(controller: RBEIntroViewController) {
            controller.transition(to: ReadyState())
        }

    }

    class InvalidState: BaseErrorState {}

    class CancellingState: State {}

    class ReadyState: CancellableState {

        override func start(controller: RBEIntroViewController) {
            controller.transition(to: StartingState())
        }

    }

    class StartingState: State {

        override func didStart(controller: RBEIntroViewController) {
            controller.transition(to: StartedState())
        }

        override func handleError(_ error: Error, controller: RBEIntroViewController) {
            controller.transition(to: ErrorState())
        }

    }

    class StartedState: State {}

    class ErrorState: BaseErrorState {}

}
