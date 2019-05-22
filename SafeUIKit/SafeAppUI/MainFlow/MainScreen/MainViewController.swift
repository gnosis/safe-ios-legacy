//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol MainViewControllerDelegate: class {
    func mainViewDidAppear()
    func createNewTransaction(token: String)
    func openMenu()
    func manageTokens()
    func openAddressDetails()
}

public protocol SegmentController {

    var segmentItem: SegmentBarItem { get }

}


extension AssetViewViewController: SegmentController {

    public var segmentItem: SegmentBarItem {
        return SegmentBarItem(title: LocalizedString("assets_capitalized", comment: "Assets tab title"),
                              image: Asset.MainScreenHeader.coins.image)
    }

}

extension TransactionViewViewController: SegmentController {

    public var segmentItem: SegmentBarItem {
        return SegmentBarItem(title: LocalizedString("transactions_capitalized", comment: "Transactions tab title"),
                              image: Asset.MainScreenHeader.arrows.image)
    }

}

class MainViewController: UIViewController {

    /// This view provides background color when the headerView scaled down and reveals transparent regions in the back.
    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var headerView: MainHeaderView!
    @IBOutlet weak var segmentBar: SegmentBar!
    @IBOutlet weak var containerView: UIView!

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
        containerView.backgroundColor = ColorName.paleGrey.color
        view.backgroundColor = containerView.backgroundColor
        headerBackgroundView.backgroundColor = .white
        headerView.backgroundColor = .white
        segmentBar.backgroundColor = .white

        navigationItem.rightBarButtonItem = .menuButton(target: self, action: #selector(openMenu))

        segmentBar.addTarget(self, action: #selector(didChangeSegment(bar:)), for: .valueChanged)

        viewControllers = [assetViewController, transactionViewController]
        selectedViewController = assetViewController

        headerView.address = ApplicationServiceRegistry.walletService.selectedWalletAddress
        headerView.identiconView.tapAction = assetViewController.delegate?.openAddressDetails

        assetViewController.scrollDelegate = assetViewScrollDelegate
        assetViewScrollDelegate.setUp(assetViewController.tableView, headerView)

        transactionViewController.scrollDelegate = transactionViewScrollDelegate
        transactionViewScrollDelegate.setUp(transactionViewController.tableView, headerView)
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

    // Called from AssetViewViewController -> AddTokenFooterView by responder chain
    @IBAction func manageTokens(_ sender: Any) {
        assetViewController.delegate?.manageTokens()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Without async appearing animations is not finished yet, but we call in delegate
        // system push notifications alert. This causes wrong views displaying.
        DispatchQueue.main.async {
            self.assetViewController.delegate?.mainViewDidAppear()
        }
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
        addressLabel.textColor = ColorName.dusk.color
    }

}
