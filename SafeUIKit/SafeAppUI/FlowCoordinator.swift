//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

/**
 User interface is implemented as view controllers managed by flow coordinators.

 FlowCoordinator coordinates transitions between view controllers in a flow.

 A flow is a coherent set of view controllers interacting with each other in some way in order to accomplish
 one use case or part of a use case.

 The minimum number of controllers in a flow is 2.

 A view controller must not present any other view controller. Rather, the FlowCoordinator handles what controller to
 present next and how to present it.

 A detached controller is a view controller that implements a single task by itself, without other controllers.
 Detached controller must have public factory method with completion closure. That is needed to use detached controller
 from several flows.
 For example, UnlockViewController handles password or biometry authentication, and is used from different parts of the
 app, whether after restart or transaction confirmation must be authorized.

 Each coordinator sets up its initial controllers in the `setUp()` method.

 When one flow transitions into a child flow, the FlowCoordinator calls `enter(flow:)`. This method
 calls `setUp()` on a child flow coordinator.

 During `setUp()`, flow coordinator creates necessary view controllers and uses navigation-related methods
 for presenting view controllers. For example, `MasterPasswordFlowCoordinator` creates SetPasswordViewController and
 pushes it onto navigation stack using `push()` method.

*/
open class FlowCoordinator {

    private var flowCompletion: (() -> Void)?
    public private(set) var rootViewController: UIViewController!
    private var checkpoints: [UIViewController] = []

    var navigationController: UINavigationController {
        if let controller = rootViewController as? UINavigationController {
            return controller
        } else {
            precondition(rootViewController != nil, "FlowCoordinator has nil root controller")
            precondition(rootViewController?.navigationController != nil,
                         "FlowCoordinator's root controller doesn't have navigation controller")
            return rootViewController.navigationController!
        }
    }

    public init(rootViewController: UIViewController? = nil) {
        self.rootViewController = rootViewController
    }

    open func setUp() {
        // override in subclasses
    }

    func enter(flow coordinator: FlowCoordinator, completion: (() -> Void)? = nil) {
        coordinator.rootViewController = rootViewController
        coordinator.flowCompletion = completion
        coordinator.setUp()
    }

    func exitFlow() {
        precondition(Thread.isMainThread, "Exit flow should be called on main thread")
        flowCompletion?()
    }

    func push(_ controller: UIViewController) {
        let isAnythingInNavigationStack = !navigationController.viewControllers.isEmpty
        navigationController.pushViewController(controller, animated: isAnythingInNavigationStack)
    }

    func pop(to controller: UIViewController? = nil) {
        if let controller = controller {
            navigationController.popToViewController(controller, animated: true)
        } else {
            navigationController.popViewController(animated: true)
        }
    }

    func saveCheckpoint() {
        if let controller = navigationController.topViewController {
            checkpoints.append(controller)
        }
    }

    func popToLastCheckpoint() {
        if let controller = checkpoints.last {
            checkpoints.removeLast()
            pop(to: controller)
        } else {
            pop()
        }
    }

    func clearNavigationStack() {
        navigationController.setViewControllers([], animated: false)
    }

    func presentModally(_ controller: UIViewController) {
        rootViewController.present(controller, animated: true, completion: nil)
    }

    func dismissModal() {
        if rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: true, completion: nil)
        }
    }

}

public final class TransparentNavigationController: UINavigationController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        makeNavBarTransparent()
    }

    func makeNavBarTransparent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }

}
