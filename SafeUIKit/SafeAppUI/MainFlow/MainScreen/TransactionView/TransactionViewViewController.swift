//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BlockiesSwift
import MultisigWalletApplication
import Common
import SafeUIKit

public protocol TransactionViewViewControllerDelegate: class {
    func didSelectTransaction(id: String)
}

public class TransactionViewViewController: UITableViewController, EventSubscriber {

    private var model = CollectionUIModel<TransactionGroupData>()
    private var pendingAnimatedTransactions = Set<String>()
    public weak var delegate: TransactionViewViewControllerDelegate?
    weak var scrollDelegate: ScrollDelegate?
    let emptyView = EmptyResultsView()
    let rowHeight: CGFloat = 70
    private let updateQueue = DispatchQueue(label: "TransactionDetailsUpdateQueue",
                                            qos: .userInitiated)

    public static func create() -> TransactionViewViewController {
        return StoryboardScene.Main.transactionsTableViewController.instantiate()
    }

    private enum Strings {
        static let noTransactions = LocalizedString("empty_safe_transactions_message", comment: "No transactions yet")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        emptyView.text = Strings.noTransactions
        tableView.register(TransactionsGroupHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: "TransactionsGroupHeaderView")
        tableView.register(UINib(nibName: "TransactionTableViewCell",
                                 bundle: Bundle(for: TransactionTableViewCell.self)),
                           forCellReuseIdentifier: "TransactionTableViewCell")
        tableView.sectionHeaderHeight = TransactionsGroupHeaderView.height
        tableView.estimatedSectionHeaderHeight = tableView.sectionHeaderHeight
        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.separatorStyle = .none
        ApplicationServiceRegistry.walletService.subscribeForTransactionUpdates(subscriber: self)
        displayUpdatedData()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    func reloadData() {
        dispatch.asynchronous(updateQueue) { [weak self] in
            let sections = ApplicationServiceRegistry.walletService.grouppedTransactions()
            self?.model = CollectionUIModel(sections)
        }.then(.main) { [weak self] in
            self?.displayUpdatedData()
        }
    }

    func displayUpdatedData() {
        tableView.reloadData()
        tableView.backgroundView = model.isEmpty ? emptyView : nil
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MainTrackingEvent.transactions)
    }

    public override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        guard parent != nil else { return }
        scrollDelegate?.scrollToTop?(tableView)
    }

    // MARK: - Table view data source

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return model.sectionCount
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.itemCount(section: section)
    }

    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let group = model[section] else { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TransactionsGroupHeaderView")
            as! TransactionsGroupHeaderView
        view.configure(group: group)
        return view
    }

    // GH-500 (crash) fix
    // reloadTable() and cellForRow are not synchronous, but can run in different run loop cycles
    // that's why reloading model in the background can invalidate saved `numberOfRows` inside the UITableView
    // that is why guard to ensure we have correct indexes, i.e. in range of the model's count.
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let transaction = model[indexPath] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell",
                                                 for: indexPath) as! TransactionTableViewCell
        cell.configure(transaction: transaction)
        return cell
    }

    public override func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
        guard let transaction = model[indexPath], let cell = cell as? TransactionTableViewCell else { return }
        if transaction.status == .pending && !pendingAnimatedTransactions.contains(transaction.id) {
            cell.showProgress(transaction, animated: true)
            pendingAnimatedTransactions.insert(transaction.id)
        } else {
            cell.showProgress(transaction, animated: false)
        }
        TooltipControlCenter.showFirstTimeTooltip(persistenceKey: "io.gnosis.safe.transactions_view.visited",
                                                  target: cell,
                                                  parent: view,
                                                  text: LocalizedString("transaction_details_here", comment: "Tap"))
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let transaction = model[indexPath] else { return }
        delegate?.didSelectTransaction(id: transaction.id)
    }

    // MARK: - Scroll View delegate

    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }

    override public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                                   withVelocity velocity: CGPoint,
                                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollDelegate?.scrollViewWillEndDragging?(scrollView,
                                                   withVelocity: velocity,
                                                   targetContentOffset: targetContentOffset)
    }

    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    // MARK: EventSubscriber

    public func notify() {
        reloadData()
    }

}
