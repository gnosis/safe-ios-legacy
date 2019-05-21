//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common
import MultisigWalletApplication
import BigInt

protocol MainViewControllerDelegate: class {
    func mainViewDidAppear()
    func createNewTransaction(token: String)
    func openMenu()
    func manageTokens()
    func openAddressDetails()
}

@objc protocol ScrollDelegate: UIScrollViewDelegate {

    @objc optional func viewDidAppear(_ scrollView: UIScrollView)
}

final class MainViewController: UIViewController {

    @IBOutlet weak var safeIdenticonView: IdenticonView!
    @IBOutlet weak var safeAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!

    private let assetViewScrollDelegate = HeaderScrollDelegate()
    private let transactionViewScrollDelegate = HeaderScrollDelegate()

    private var contentController: MainContentViewController {
        return self.children.first as! MainContentViewController
    }
    private weak var delegate: (MainViewControllerDelegate & TransactionsTableViewControllerDelegate)?

    static func create(delegate: MainViewControllerDelegate & TransactionsTableViewControllerDelegate)
        -> MainViewController {
            let controller = StoryboardScene.Main.mainViewController.instantiate()
            controller.delegate = delegate
            return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white // ColorName.paleGrey.color
        safeAddressLabel.textColor = ColorName.dusk.color

        guard let address = ApplicationServiceRegistry.walletService.selectedWalletAddress else { return }
        ApplicationServiceRegistry.logger.info("Safe address: \(address)")

        navigationItem.setRightBarButton(UIBarButtonItem.menuButton(target: self, action: #selector(openMenu)),
                                         animated: false)
        safeAddressLabel.address = address
        safeIdenticonView.seed = address
        safeIdenticonView.tapAction = {
            self.delegate?.openAddressDetails()
        }

        let segmentBar = contentController.segmentBar
        segmentBar.removeFromSuperview()
        view.addSubview(segmentBar)
        segmentBar.removeConstraints(segmentBar.constraints)
        NSLayoutConstraint.activate([
            segmentBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentBar.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            segmentBar.heightAnchor.constraint(equalToConstant: assetViewScrollDelegate.segmentBarHeight)])

        assetViewScrollDelegate.headerView = headerView
        assetViewScrollDelegate.headerHeightConstraint = headerHeightConstraint

        transactionViewScrollDelegate.headerView = headerView
        transactionViewScrollDelegate.headerHeightConstraint = headerHeightConstraint

        assetViewScrollDelegate.setUp(contentController.tokensController.tableView)
        transactionViewScrollDelegate.setUp(contentController.transactionsController.tableView)

        // re-select otherwise the markers of tabs are lost (constraints removed)
        contentController.selectedViewController = contentController.tokensController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = Asset.shadow.image
    }

    @objc func openMenu(_ sender: Any) {
        delegate?.openMenu()
    }

    // Called from AddTokenFooterView by responder chain
    @IBAction func manageTokens(_ sender: Any) {
        delegate?.manageTokens()
    }

    func showTransactionList() {
        if let contentVC = self.children.first as? MainContentViewController {
            contentVC.showTransactionList()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Without async appearing animations is not finished yet, but we call in delegate
        // system push notifications alert. This causes wrong views displaying.
        DispatchQueue.main.async {
            self.delegate?.mainViewDidAppear()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == StoryboardSegue.Main.mainContentViewControllerSeague.rawValue {
            let controller = segue.destination as! MainContentViewController
            controller.delegate = delegate
            controller.transactionsControllerDelegate = delegate
            controller.tokensController.scrollDelegate = assetViewScrollDelegate
            controller.transactionsController.scrollDelegate = transactionViewScrollDelegate
        }
    }

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

    weak var headerView: UIView!
    weak var headerHeightConstraint: NSLayoutConstraint!

    func setUp(_ scrollView: UIScrollView) {
        let contentInset = UIEdgeInsets(top: segmentBarHeight + maxHeaderHeight, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        scrollView.contentOffset = CGPoint(x: 0, y: -contentInset.top)
    }

    func viewDidAppear(_ scrollView: UIScrollView) {
        let topOffset = CGPoint(x: scrollView.contentOffset.x, y: -scrollView.contentInset.top)

        let needsToChangeHeight = headerHeightConstraint.constant != maxHeaderHeight
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

        headerHeightConstraint.constant = clampedHeight

        let x = clampedHeight / maxHeaderHeight
        let scale = x * sqrt(x)
        headerView.transform = CGAffineTransform(scaleX: scale, y: scale)

        let alpha = max(0, (x - minAlpha) / (maxAlpha - minAlpha))
        headerView.alpha = alpha
        headerView.setNeedsLayout()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beginHeight = headerHeightConstraint.constant
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee

        let targetHeight = maxHeaderHeight - (targetOffset.y + scrollView.contentInset.top)
        let targetClampedHeight = min(max(minHeaderHeight, targetHeight), maxHeaderHeight)

        let wasMinimized  = beginHeight < middleThreshold

        let shouldMinimize =  wasMinimized && targetClampedHeight < minimizationThreshold ||
            !wasMinimized && targetClampedHeight < maximizationThreshold

        if (minHeaderHeight...maxHeaderHeight).contains(targetHeight) {
            let newTargetOffsetY = maxHeaderHeight - (shouldMinimize ? minHeaderHeight : maxHeaderHeight) - scrollView.contentInset.top
            let newOffset = CGPoint(x: targetOffset.x, y: newTargetOffsetY)
            targetContentOffset.pointee = newOffset
        }

    }


}
