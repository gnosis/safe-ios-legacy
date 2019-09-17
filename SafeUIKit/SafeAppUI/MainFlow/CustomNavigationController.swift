//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

protocol InteractivePopGestureResponder {

    func interactivePopGestureShouldBegin() -> Bool

}

/// This custom navigation controller enhances default in several ways:
///   - updates status bar style based on current child view controller
///   - enables swipe back gesture even if custom back button is used (credits https://bit.ly/2RgJtI6)
///   - adds ability to block swipe back gesture by the top view controller
///     implementing InteractivePopGestureResponder protocol
class CustomNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return visibleViewController?.preferredStatusBarStyle ?? .default
    }

    private var isPushingViewController = false
    private weak var externalDelegate: UINavigationControllerDelegate?

    override var delegate: UINavigationControllerDelegate? {
        didSet {
            if !(delegate is CustomNavigationController) {
                externalDelegate = delegate
                super.delegate = oldValue
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        isPushingViewController = true
        super.pushViewController(viewController, animated: animated)
    }

}

extension CustomNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is UIScreenEdgePanGestureRecognizer else { return true }
        if let responder = topViewController as? InteractivePopGestureResponder,
            !responder.interactivePopGestureShouldBegin() {
            return false
        }
        return viewControllers.count > 1 && !isPushingViewController
    }

}

// swiftlint:disable line_length
extension CustomNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        isPushingViewController = false
        externalDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        externalDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return externalDelegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }

    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return externalDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? UIApplication.shared.statusBarOrientation
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return externalDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return externalDelegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }

}

public extension UINavigationController {

    func viewController(before vc: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: vc), index > 0 else { return nil }
        return viewControllers[index - 1]
    }

}
