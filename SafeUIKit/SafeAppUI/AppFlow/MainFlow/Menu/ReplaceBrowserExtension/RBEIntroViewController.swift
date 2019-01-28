//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class RBEIntroViewController: UIViewController {

    @IBOutlet weak var stateLabel: UILabel!
    var startButtonItem: UIBarButtonItem!
    var state: State = LoadingState()

    static func create() -> RBEIntroViewController {
        return RBEIntroViewController(nibName: "\(self)", bundle: Bundle(for: self))
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        startButtonItem = UIBarButtonItem(title: "some", style: .plain, target: nil, action: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        stateLabel.text = "Loading"
    }

    func transition(to newState: State) {
        state = newState
        newState.didEnter(controller: self)
    }

    // MARK: Actions

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

    // MARK: Base States

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
