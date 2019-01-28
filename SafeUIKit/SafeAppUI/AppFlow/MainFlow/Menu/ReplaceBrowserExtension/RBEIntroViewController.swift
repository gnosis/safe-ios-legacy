//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class RBEIntroViewController: UIViewController {

    @IBOutlet weak var stateLabel: UILabel!
    var state: State = LoadingState()

    static func create() -> RBEIntroViewController {
        let aClass = RBEIntroViewController.self
        let nibName = "\(aClass)"
        let bundle = Bundle(for: aClass)
        return RBEIntroViewController(nibName: nibName, bundle: bundle)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        stateLabel.text = "Loading"
    }

    public func handleError(_ error: Error) {
        state.handleError(error, controller: self)
    }

    public func back() {
        state.back(controller: self)
    }

    public func didLoad() {
        state.didLoad(controller: self)
    }

    public func start() {
        state.start(controller: self)
    }

    public func didStart() {
        state.didStart(controller: self)
    }

    public func retry() {
        state.retry(controller: self)
    }
}

extension RBEIntroViewController {

    class State {

        func handleError(_ error: Error, controller: RBEIntroViewController) {

        }

        func back(controller: RBEIntroViewController) {

        }

        func didLoad(controller: RBEIntroViewController) {

        }

        func start(controller: RBEIntroViewController) {

        }

        func didStart(controller: RBEIntroViewController) {

        }

        func retry(controller: RBEIntroViewController) {

        }

    }

    class CancellableState: State {

        override func back(controller: RBEIntroViewController) {
            controller.state = CancellingState()
        }

    }


    class LoadingState: CancellableState {

        override func handleError(_ error: Error, controller: RBEIntroViewController) {
            controller.state = InvalidState()
        }

        override func didLoad(controller: RBEIntroViewController) {
            controller.state = ReadyState()
        }
    }

    class BaseErrorState: CancellableState {
        override func retry(controller: RBEIntroViewController) {
            controller.state = LoadingState()
        }

    }


    class InvalidState: BaseErrorState {

    }

    class CancellingState: State {

    }

    class ReadyState: CancellableState {

        override func start(controller: RBEIntroViewController) {
            controller.state = StartingState()
        }
    }

    class StartingState: State {

        override func didStart(controller: RBEIntroViewController) {
            controller.state = StartedState()
        }

        override func handleError(_ error: Error, controller: RBEIntroViewController) {
            controller.state = ErrorState()
        }
    }

    class StartedState: State {

    }

    class ErrorState: BaseErrorState {

    }

}
