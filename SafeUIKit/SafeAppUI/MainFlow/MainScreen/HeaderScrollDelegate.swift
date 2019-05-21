//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

@objc protocol ScrollDelegate: UIScrollViewDelegate {

    @objc optional func viewDidAppear(_ scrollView: UIScrollView)
}

class HeaderScrollDelegate: NSObject, ScrollDelegate {

    let segmentBarHeight: CGFloat = 46
    let maxHeaderHeight: CGFloat = 130
    let minHeaderHeight: CGFloat = 0
    let minAlpha: CGFloat = 0.3
    let maxAlpha: CGFloat = 1.0
    var maximizationThreshold: CGFloat { return maxHeaderHeight * 0.8 }
    var minimizationThreshold: CGFloat { return maxHeaderHeight * 0.2 }
    var middleThreshold: CGFloat { return maxHeaderHeight * 0.5 }
    var beginHeight: CGFloat = 0

    weak var headerView: MainHeaderView!

    func setUp(_ scrollView: UIScrollView, _ headerView: MainHeaderView) {
        self.headerView = headerView
        let contentInset = UIEdgeInsets(top: segmentBarHeight + maxHeaderHeight, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        scrollView.contentOffset = CGPoint(x: 0, y: -contentInset.top) // triggers scrollViewDidScroll
    }

    func viewDidAppear(_ scrollView: UIScrollView) {
        let topOffset = CGPoint(x: scrollView.contentOffset.x, y: -scrollView.contentInset.top)

        let needsToChangeHeight = headerView.height != maxHeaderHeight
        let needsToScroll = topOffset != scrollView.contentOffset

        if !needsToChangeHeight {
            scrollView.contentOffset = topOffset
        } else if needsToScroll {
            scrollView.setContentOffset(topOffset, animated: true)
        } else {
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let height = maxHeaderHeight - (offset.y + scrollView.contentInset.top)
        let clampedHeight = min(max(minHeaderHeight, height), maxHeaderHeight)

        headerView.height = clampedHeight

        let x = clampedHeight / maxHeaderHeight
        let scale = x * sqrt(x)
        headerView.transform = CGAffineTransform(scaleX: scale, y: scale)

        let alpha = max(0, (x - minAlpha) / (maxAlpha - minAlpha))
        headerView.alpha = alpha
        headerView.setNeedsLayout()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beginHeight = headerView.height
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee

        let targetHeight = maxHeaderHeight - (targetOffset.y + scrollView.contentInset.top)
        let targetClampedHeight = min(max(minHeaderHeight, targetHeight), maxHeaderHeight)

        let wasMinimized = beginHeight < middleThreshold

        let shouldMinimize = wasMinimized && targetClampedHeight < minimizationThreshold ||
            !wasMinimized && targetClampedHeight < maximizationThreshold

        if (minHeaderHeight...maxHeaderHeight).contains(targetHeight) {
            let newTargetOffsetY = maxHeaderHeight -
                (shouldMinimize ? minHeaderHeight : maxHeaderHeight) -
                scrollView.contentInset.top
            let newOffset = CGPoint(x: targetOffset.x, y: newTargetOffsetY)
            targetContentOffset.pointee = newOffset
        }

    }

}
