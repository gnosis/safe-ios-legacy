//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

// Non-interactive transition that would show the dimmed view as a background.

// Creates OverlayTransitionAnimator for apperance and dismissal transitions
class OverlayAnimatorFactory: NSObject, UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayTransitionAnimator(presented: presented, presenting: presenting)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayTransitionAnimator(dismissed: dismissed)
    }

}

/// Overlay transition animator - animates on or off screen animations
class OverlayTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    /// Used for appearance animation
    private weak var presented: UIViewController!
    private weak var presenting: UIViewController!

    /// Used for dismissal animation
    private weak var dismissed: UIViewController!

    /// Helps to understand what animation to play
    private var isAnimatingAppearance: Bool { return presented != nil }

    /// Animation timing
    private let defaultAnimationDuration: TimeInterval = 0.5

    // Tag used to identify dimmedView after it was added during the appearance animation
    private let dimmedViewTag: Int = 0xa2654802

    // Value that makes view fully transparent
    private let invisibleAlpha: CGFloat = 0

    // Value with 0% opacity
    private let visibleAlpha: CGFloat = 1

    // Value for semi-transparent dimming color
    private let dimmedColor = ColorName.black40.color

    /// Creates overlay animator suitable for appearance animation
    ///
    /// - Parameters:
    ///   - presented: controller that presents another controller
    ///   - presenting: controller that is put on the screen
    init(presented: UIViewController, presenting: UIViewController) {
        self.presented = presented
        self.presenting = presenting
    }

    /// Creates overaly animator suitable for dismissal animation
    ///
    /// - Parameter dismissed: controller that is put off the screen
    init(dismissed: UIViewController) {
        self.dismissed = dismissed
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isAnimatingAppearance {
            animateAppearance(using: transitionContext)
        } else {
            animateDismissal(using: transitionContext)
        }
    }

    func animateAppearance(using transitionContext: UIViewControllerContextTransitioning) {
        // transitionContext is a UIKit-provided object that gives us access to
        // the container for presented and presenting views, and any other animation-related views
        let containerView = transitionContext.containerView

        // Create and configure dimmed background view for initial animation state: invisible.

        let dimmedView = UIView(frame: containerView.bounds)
        // tag is used to find the view later during dismissal animation
        dimmedView.tag = dimmedViewTag
        dimmedView.alpha = invisibleAlpha
        dimmedView.backgroundColor = dimmedColor
        containerView.addSubview(dimmedView)

        // Configure the presentedView for initial animation state: below the containerView

        let initialOffscreenFrame = containerView.bounds.offsetBy(dx: 0, dy: containerView.bounds.height)
        let finalOnscreenFrame = containerView.bounds

        let presentedView = presented.view!
        presentedView.frame = initialOffscreenFrame
        containerView.addSubview(presentedView)

        // UIKit requires us to check context.isAnimated, else install views in final state
        guard transitionContext.isAnimated else {
            dimmedView.alpha = visibleAlpha
            presentedView.frame = finalOnscreenFrame
            transitionContext.completeTransition(true)
            return
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: { [weak self] in
                        guard let `self` = self else { return }
                        dimmedView.alpha = self.visibleAlpha
                        presentedView.frame = finalOnscreenFrame
            }, completion: { _ in
                transitionContext.completeTransition(true)
        })
    }


    func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let presentedView = dismissed.view!
        let dimmedView = containerView.viewWithTag(dimmedViewTag)!

        let finalOffscreenFrame = containerView.bounds.offsetBy(dx: 0, dy: containerView.bounds.height)

        guard transitionContext.isAnimated else {
            dimmedView.removeFromSuperview()
            presentedView.frame = finalOffscreenFrame
            transitionContext.completeTransition(true)
            return
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: { [weak self] in
                        guard let `self` = self else { return }
                        dimmedView.alpha = self.invisibleAlpha
                        presentedView.frame = finalOffscreenFrame
            }, completion: { _ in
                dimmedView.removeFromSuperview()
                transitionContext.completeTransition(true)
        })

    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return defaultAnimationDuration
    }

}
