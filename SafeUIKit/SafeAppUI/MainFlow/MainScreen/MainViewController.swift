//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol MainViewControllerDelegate: class {
    func createNewTransaction(token: String)
    func openMenu()
    func manageTokens()
    func openAddressDetails()
    func upgradeContract()
}

public protocol SegmentController {

    var segmentItem: SegmentBarItem { get }

}


extension AssetViewViewController: SegmentController {

    public var segmentItem: SegmentBarItem {
        return SegmentBarItem(title: LocalizedString("assets", comment: "Assets tab title").uppercased(),
                              image: Asset.MainScreenHeader.coins.image)
    }

}

extension TransactionViewViewController: SegmentController {

    public var segmentItem: SegmentBarItem {
        return SegmentBarItem(title: LocalizedString("transactions", comment: "Transactions tab title").uppercased(),
                              image: Asset.MainScreenHeader.arrows.image)
    }

}

class MainViewController: UIViewController {

    /// This view provides background color when the headerView scaled down and reveals transparent regions in the back.
    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var headerView: MainHeaderView!
    @IBOutlet weak var segmentBar: SegmentBar!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bannerView: MainBannerView!

    let assetViewController = AssetViewViewController()
    // swiftlint:disable:next weak_delegate
    let assetViewScrollDelegate = HeaderScrollDelegate()

    let transactionViewController = TransactionViewViewController.create()
    // swiftlint:disable:next weak_delegate
    let transactionViewScrollDelegate = HeaderScrollDelegate()

    static func create(delegate: MainViewControllerDelegate & TransactionViewViewControllerDelegate)
        -> MainViewController {
            let controller = StoryboardScene.Main.mainViewController.instantiate()
            controller.assetViewController.delegate = delegate
            controller.transactionViewController.delegate = delegate
            return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.backgroundColor = ColorName.white.color
        view.backgroundColor = containerView.backgroundColor
        headerBackgroundView.backgroundColor = ColorName.snowwhite.color
        headerView.backgroundColor = ColorName.snowwhite.color
        segmentBar.backgroundColor = ColorName.snowwhite.color

        navigationItem.rightBarButtonItem = .menuButton(target: self, action: #selector(openMenu))

        segmentBar.addTarget(self, action: #selector(didChangeSegment(bar:)), for: .valueChanged)

        viewControllers = [assetViewController, transactionViewController]
        selectedViewController = assetViewController

        headerView.address = ApplicationServiceRegistry.walletService.selectedWalletAddress
        headerView.button.addTarget(self, action: #selector(didTapAddress), for: .touchUpInside)

        bannerView.onTap = didTapBanner
        bannerView.text = LocalizedString("upgrade_required", comment: "Security upgrade required")

        assetViewController.scrollDelegate = assetViewScrollDelegate
        assetViewScrollDelegate.setUp(assetViewController.tableView, headerView)

        transactionViewController.scrollDelegate = transactionViewScrollDelegate
        transactionViewScrollDelegate.setUp(transactionViewController.tableView, headerView)

        updateBannerView()

        ApplicationServiceRegistry.contractUpgradeService.subscribeForContractUpgrade { [weak self] in
            self?.updateBannerView()
        }
    }

    func updateBannerView() {
        if !ApplicationServiceRegistry.contractUpgradeService.isAvailable {
            bannerView.height = 0
            bannerView.isHidden = true
        }
        assetViewScrollDelegate.verticalContentInset = bannerView.height
        assetViewScrollDelegate.scrollViewDidScroll(assetViewScrollDelegate.scrollView)

        transactionViewScrollDelegate.verticalContentInset = bannerView.height
        transactionViewScrollDelegate.scrollViewDidScroll(transactionViewScrollDelegate.scrollView)
    }

    func showTransactionList() {
        selectedViewController = transactionViewController
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
        assetViewController.delegate?.openMenu()
    }

    func didTapBanner() {
        assetViewController.delegate?.upgradeContract()
    }

    // Called from AssetViewViewController -> AddTokenFooterView by responder chain
    @IBAction func manageTokens(_ sender: Any) {
        assetViewController.delegate?.manageTokens()
    }

    @IBAction func didTapAddress(_ sender: Any) {
        assetViewController.delegate?.openAddressDetails()
    }

    // MARK: - Segments Management

    open var viewControllers = [UIViewController & SegmentController]() {
        didSet {
            update()
            selectedViewController = nil
        }
    }
    open var selectedViewController: (UIViewController & SegmentController)? {
        willSet {
            precondition(newValue == nil || viewControllers.contains { $0 === newValue })
        }
        didSet {
            if oldValue !== selectedViewController {
                updateSelection(old: oldValue)
            }
        }
    }

    func update() {
        guard isViewLoaded else { return }
        segmentBar.items = viewControllers.map { $0.segmentItem }
    }

    private func updateSelection(old oldController: (UIViewController & SegmentController)?) {
        guard isViewLoaded else { return }
        if let controller = oldController {
            removeChild(controller)
        }
        if let controller = selectedViewController {
            addChildContent(controller)
            let index = viewControllers.firstIndex { $0 === controller }!
            segmentBar.selectedItem = segmentBar.items[index]
        } else {
            segmentBar.selectedItem = nil
        }
    }

    private func removeChild(_ controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        view.setNeedsLayout()
    }

    private func addChildContent(_ controller: UIViewController) {
        addChild(controller)
        controller.view.frame = containerView.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
        view.setNeedsLayout()
    }

    @objc private func didChangeSegment(bar: SegmentBar) {
        if let selected = bar.selectedItem, let index = bar.items.firstIndex(of: selected) {
            selectedViewController = viewControllers[index]
        } else {
            selectedViewController = nil
        }
    }

}

class MainHeaderView: UIView {

    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var addressLabel: EthereumAddressLabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var button: UIButton!

    var height: CGFloat {
        get { return heightConstraint.constant }
        set { heightConstraint.constant = newValue; setNeedsLayout() }
    }

    var address: String? {
        didSet {
            assert(Thread.isMainThread)
            addressLabel.address = address
            if let address = address {
                identiconView.seed = address
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addressLabel.textColor = ColorName.darkBlue.color
    }

}
