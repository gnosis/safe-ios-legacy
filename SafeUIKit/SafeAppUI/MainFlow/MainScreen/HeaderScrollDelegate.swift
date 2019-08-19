//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

@objc protocol ScrollDelegate: UIScrollViewDelegate {
    @objc optional func scrollToTop(_ scrollView: UIScrollView)
}

/// This class encapsulates layout calculations for dynamically adjusting MainHeaderView's height based on
/// the tableView's scroll position.
///
/// The desired effect is that when user starts scrolling down, the header is minimized, but when content is scrolled
/// back to the top, the header is maximized again.
///
/// In case the header been minimized and user switches
/// tabs, then it should automatically scroll to the top and show maximized header.
///
/// In case user releases touch while the header is displayed in intermediate state, we want it automatically
/// animate to either minimized or maximized position (snap to the closes edge).
///
/// Alongside header minimization we scale it down and reduce the alpha so that it nicely disappears.
///
/// # Usage
/// Relay the `viewDidAppear()`, `scrollViewDidScroll()`, `scrollViewWillBeginDragging()` and
/// `scrollViewWillEndDragging()` method calls from table view controller to this object.
/// For setting up the scroll view properly, call the `setUp()` on `viewDidLoad()`
///
/// # Layout assumptions
/// This algorithm assumes that tableView's frame is the same as controller's view frame,
/// that the headerView is covering the tableView, and that there is additional segmentBar that is attached
/// below the headerView.
///
/// The `setUp()` changes tableView's contentInset to adjust for the headerView and segmentBar heights.
///
/// We assume that the `setUp()` will be called with exactly the same `scrollView` object as with other
/// methods accepting `scrollView`
///
class HeaderScrollDelegate: NSObject, ScrollDelegate {

    let segmentBarHeight: CGFloat = 46

    // Header's height decreases when scrollView.contentOffset.y increases, and vice versa.

    let minHeaderHeight: CGFloat = 0
    let maxHeaderHeight: CGFloat = 130

    var verticalContentInset: CGFloat = 0

    // Alpha decreases when header height decreases.

    /// When height reaches X percent of the maximum, then alpha will become 0 and header will be transparent.
    let minAlphaHeight: CGFloat = 0.3
    /// When height reaches X percent of the maximum, then alpha will become 1 and header will be opaque.
    let maxAlphaHeight: CGFloat = 1.0

    /// Upon end of user touch, if the height is less than this value, then header will minimize.
    var minimizationThreshold: CGFloat { return maxHeaderHeight * 0.2 }
    /// Upon end of user touch, if the height is more than this value, then header will maximize
    var maximizationThreshold: CGFloat { return maxHeaderHeight * 0.8 }

    /// Helps to determine direction of the height change: less than middle - minimization, otherwise - maximization
    var middleThreshold: CGFloat { return maxHeaderHeight * 0.5 }

    /// Remembers value when scroll view began dragging (touches started)
    var beginHeight: CGFloat = 0

    /// The view that will be manipulated
    weak var headerView: MainHeaderView!
    weak var scrollView: UIScrollView!

    /// Sets up scroll view's position and initial header height
    func setUp(_ scrollView: UIScrollView, _ headerView: MainHeaderView) {
        self.headerView = headerView
        self.scrollView = scrollView
        compensateInsetsIfContentNotTallEnough()
        // triggers scrollViewDidScroll
        scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
    }

    /// Always scrolls to the top and maximizes the header.
    func scrollToTop(_ scrollView: UIScrollView) {
        let topOffset = CGPoint(x: scrollView.contentOffset.x,
                                y: height(offset: maxHeaderHeight, scrollView: scrollView))

        if headerView.height == maxHeaderHeight {
            scrollView.setContentOffset(topOffset, animated: false)
        } else if topOffset != scrollView.contentOffset {
            scrollView.setContentOffset(topOffset, animated: true)
        } else {
            // the height is out of sync with contentOffset, trigger the height update
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0,
                           options: [],
                           animations: {
                            self.scrollViewDidScroll(scrollView)
            }, completion: nil)
        }
    }

    func resetToTop() {
        var offset = scrollView.contentOffset
        offset.y = -(maxHeaderHeight + segmentBarHeight + verticalContentInset)
        scrollView.setContentOffset(offset, animated: false)
    }

    /// Updates height based on the 'y' content offset, updates scale transform based on height, and alpha based on
    /// height.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        compensateInsetsIfContentNotTallEnough()

        let newHeight = clampedHeight(height(offset: scrollView.contentOffset.y, scrollView: scrollView))
        headerView.height = newHeight

        let relativeHeight = newHeight / maxHeaderHeight

        // Using f(x) = x^1.5 gives nice scaling interpolation for range [0 ... 1]
        let scale = relativeHeight * sqrt(relativeHeight)
        headerView.transform = CGAffineTransform(scaleX: scale, y: scale)

        let alpha = max(0, (relativeHeight - minAlphaHeight) / (maxAlphaHeight - minAlphaHeight))
        headerView.alpha = alpha
        headerView.setNeedsLayout()
    }

    /// Needed to prevent edge case when header is not fully minimized/maximized when scrolled to bottom.
    func compensateInsetsIfContentNotTallEnough() {
        // top inset must always stay the same, otherwise scrolling start flickering
        let top = maxHeaderHeight + segmentBarHeight + verticalContentInset
        let maxVisibleContentHeight = scrollView.frame.height - segmentBarHeight
        let compensatedBottom = max(0, maxVisibleContentHeight - scrollView.contentSize.height)
        let contentInset = UIEdgeInsets(top: top, left: 0, bottom: compensatedBottom, right: 0)
        // exit if pulled to refresh (changing contentInset while refresh control is active messes up scrolling)
        // https://stackoverflow.com/a/36489805/7822368
        guard scrollView.contentOffset.y >= -top else { return }
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: headerView.height, left: 0, bottom: 0, right: 0)
    }

    /// Returns target header height based on contentOffset's y (and vice versa)
    private func height(offset: CGFloat, scrollView: UIScrollView) -> CGFloat {
        return maxHeaderHeight - (offset + scrollView.contentInset.top)
    }

    /// Returns height limited to (min, max) height bounds
    private func clampedHeight(_ height: CGFloat) -> CGFloat {
        return min(max(minHeaderHeight, height), maxHeaderHeight)
    }

    /// Touches started
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beginHeight = headerView.height
    }

    /// Touches ended. We use the `targetContentOffset` to calculate target height, and then
    /// adjust the `targetContentOffset` for the updated target height.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee

        let targetHeight = height(offset: targetOffset.y, scrollView: scrollView)
        let targetClampedHeight = clampedHeight(targetHeight)

        let wasMinimized = beginHeight < middleThreshold

        let shouldMinimize = wasMinimized && targetClampedHeight < minimizationThreshold ||
            !wasMinimized && targetClampedHeight < maximizationThreshold

        if (minHeaderHeight...maxHeaderHeight).contains(targetHeight) {
            let newTargetHeight = shouldMinimize ? minHeaderHeight : maxHeaderHeight
            let newOffset = CGPoint(x: targetOffset.x, y:
                // offset from height is the same formula as height from offset.
                height(offset: newTargetHeight, scrollView: scrollView))
            targetContentOffset.pointee = newOffset
        }

    }

}
