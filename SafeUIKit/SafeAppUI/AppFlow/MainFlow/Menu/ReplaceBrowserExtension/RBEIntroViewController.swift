//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class RBEIntroViewController: UIViewController {

    var startButtonItem: UIBarButtonItem!
    var backButtonItem: UIBarButtonItem!
    var state: State = LoadingState()

    @IBOutlet weak var feeCalculationView: FeeCalculationView!

    struct Strings {
        var start = LocalizedString("navigation.start", comment: "Start")
        var back = LocalizedString("navigation.back", comment: "Back")
    }

    var strings = Strings()

    public static func create() -> RBEIntroViewController {
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
        startButtonItem = UIBarButtonItem(title: strings.start, style: .done, target: nil, action: nil)
        backButtonItem = UIBarButtonItem(title: strings.back, style: .plain, target: nil, action: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        transition(to: state)
    }

    public override func willMove(toParent parent: UIViewController?) {
        guard let navigationController = parent as? UINavigationController else { return }
        assert(navigationController.topViewController === self, "Unexpected UINavigationController behavior")
        guard navigationController.viewControllers.count > 1,
            let index = navigationController.viewControllers.firstIndex(where: { $0 == self }) else { return }
        state.willPush(controller: self, onTopOf: navigationController.viewControllers[index - 1])
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
