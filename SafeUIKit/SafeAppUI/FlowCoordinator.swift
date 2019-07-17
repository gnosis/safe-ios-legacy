//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

/**
 User interface is implemented as view controllers managed by flow coordinators.

 FlowCoordinator coordinates transitions between view controllers in a flow.

 A flow is a coherent set of view controllers interacting with each other in some way in order to accomplish
 one use case or part of a use case.

 The minimum number of controllers in a flow is 2.

 A view controller must not present any other view controller. Rather, the FlowCoordinator handles what controller to
 present next and how to present it.

 A reusable detached controller is a view controller that implements a single task by itself, without other controllers.
 Detached controller must have public factory method with completion closure (if one completion block is required) or
 a factory with a delegate otherwise. That is needed to use detached controller from several flows.
 For example, UnlockViewController handles password or biometry authentication, and is used from different parts of the
 app, whether after restart or transaction confirmation must be authorized.

 Each coordinator sets up its initial controllers in the `setUp()` method.

 When one flow transitions into a child flow, the FlowCoordinator calls `enter(flow:)`. This method
 calls `setUp()` on a child flow coordinator.

 During `setUp()`, flow coordinator creates necessary view controllers and uses navigation-related methods
 for presenting view controllers. For example, `MasterPasswordFlowCoordinator` creates PasswordViewController and
 pushes it onto navigation stack using `push()` method.

*/
open class FlowCoordinator {

    private var flowCompletion: (() -> Void)?
    private let navigationTracker = NavigationControllerTransitionTracker()
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
        precondition(Thread.isMainThread, "Enter flow should be called on main thread")
        coordinator.rootViewController = rootViewController
        coordinator.flowCompletion = completion
        coordinator.setUp()
    }

    func exitFlow() {
        precondition(Thread.isMainThread, "Exit flow should be called on main thread")
        flowCompletion?()
    }

    func push(_ controller: UIViewController, onPop action: (() -> Void)? = nil) {
        let isAnythingInNavigationStack = !navigationController.viewControllers.isEmpty
        navigationController.pushViewController(controller, animated: isAnythingInNavigationStack)
        guard let action = action else { return }
        navigationController.delegate = navigationTracker
        navigationTracker.trackOnce(navigationController: navigationController,
                                    operation: .pop,
                                    from: controller,
                                    action: action)
    }

    func pop(to controller: UIViewController? = nil) {
        if let controller = controller, navigationController.viewControllers.contains(controller) {
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

    func removeViewControllerFromStack(_ vc: UIViewController) {
        var items = navigationController.viewControllers
        if let index = items.firstIndex(of: vc) {
            items.remove(at: index)
            navigationController.setViewControllers(items, animated: false)
        }
    }

    func presentModally(_ controller: UIViewController) {
        if let presented = rootViewController.presentedViewController {
            presented.present(controller, animated: true, completion: nil)
        } else {
            rootViewController.present(controller, animated: true, completion: nil)
        }
    }

    func dismissModal(_ completion: (() -> Void)? = nil) {
        if rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: true, completion: completion)
        }
    }

}

/// Allows to track when certain VC is popped or pushed from another VC in a navigation controller.
class NavigationControllerTransitionTracker: NSObject, UINavigationControllerDelegate {

    var observers = [(nav: WeakWrapper,
                      operation: UINavigationController.Operation?,
                      fromVC: WeakWrapper,
                      toVC: WeakWrapper,
                      action: () -> Void)]()

    func trackOnce(navigationController: UINavigationController? = nil,
                   operation: UINavigationController.Operation? = nil,
                   from fromVC: UIViewController? = nil,
                   to toVC: UIViewController? = nil,
                   action: @escaping () -> Void) {
        observers.append((WeakWrapper(navigationController),
                          operation,
                          WeakWrapper(fromVC),
                          WeakWrapper(toVC),
                          action))
    }

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let index = observers.firstIndex { observer in
            (observer.nav.ref === navigationController || observer.nav.ref == nil) &&
            (observer.operation == operation || observer.operation == nil) &&
            (observer.fromVC.ref === fromVC || observer.fromVC.ref == nil) &&
            (observer.toVC.ref === toVC || observer.toVC.ref == nil)
        }
        if let index = index {
            observers[index].action()
            observers.remove(at: index)
        }
        return nil
    }
}
