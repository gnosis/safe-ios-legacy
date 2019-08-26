//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common

final class AssetViewViewController: UITableViewController {

    weak var delegate: MainViewControllerDelegate?
    weak var scrollDelegate: ScrollDelegate?
    private var tokens = [TokenData]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let bundle = Bundle(for: AssetViewViewController.self)
        tableView.register(UINib(nibName: "BasicTableViewCell", bundle: Bundle(for: BasicTableViewCell.self)),
                           forCellReuseIdentifier: "BasicTableViewCell")
        tableView.rowHeight = BasicTableViewCell.defaultHeight
        tableView.separatorStyle = .none

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(update), for: .valueChanged)

        tableView.backgroundColor = ColorName.transparent.color
        tableView.tableFooterView = (UINib(nibName: "AddTokenFooterView",
                                           bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as! UIView)
        ApplicationServiceRegistry.walletService.subscribeOnTokensUpdates(subscriber: self)

        notify()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MainTrackingEvent.assets)
    }

    @objc func update() {
        DispatchQueue.global().async {
            ApplicationServiceRegistry.walletService.syncBalances()
        }
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        guard parent != nil else { return }
        scrollDelegate?.scrollToTop?(tableView)
    }

    // MARK: - Table view data source and delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableViewCell",
                                                 for: indexPath) as! BasicTableViewCell
        cell.configure(tokenData: tokenData(for: indexPath), displayBalance: true, displayFullName: false)
        return cell
    }

    private func tokenData(for indexPath: IndexPath) -> TokenData {
        return tokens[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.createNewTransaction(token: tokenData(for: indexPath).address)
    }

    // MARK: - Scroll View delegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                            withVelocity velocity: CGPoint,
                                            targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollDelegate?.scrollViewWillEndDragging?(scrollView,
                                                   withVelocity: velocity,
                                                   targetContentOffset: targetContentOffset)
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

}

extension AssetViewViewController: EventSubscriber {

    func notify() {
        let newTokens = ApplicationServiceRegistry.walletService.visibleTokens(withEth: true)
        let isChanged = newTokens != tokens
        tokens = newTokens
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.refreshControl?.endRefreshing()
            if isChanged {
                // when notified during scrolling, the reloadData() will cause flickering, so we allow it only on change
                self.tableView.reloadData()
            }

        }
    }

}
