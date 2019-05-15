//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BlockiesSwift
import MultisigWalletApplication
import Common
import SafeUIKit

public protocol TransactionsTableViewControllerDelegate: class {
    func didSelectTransaction(id: String)
}

public class TransactionsTableViewController: UITableViewController, EventSubscriber {

    private var model = CollectionUIModel<TransactionGroupData>()
    public weak var delegate: TransactionsTableViewControllerDelegate?
    let emptyView = TransactionsEmptyView()
    let rowHeight: CGFloat = 70
    private let updateQueue = DispatchQueue(label: "TransactionDetailsUpdateQueue",
                                            qos: .userInitiated)

    public static func create() -> TransactionsTableViewController {
        return StoryboardScene.Main.transactionsTableViewController.instantiate()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TransactionsGroupHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: "TransactionsGroupHeaderView")
        tableView.sectionHeaderHeight = TransactionsGroupHeaderView.height
        tableView.estimatedSectionHeaderHeight = tableView.sectionHeaderHeight
        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = tableView.rowHeight
        ApplicationServiceRegistry.walletService.subscribeForTransactionUpdates(subscriber: self)
        displayUpdatedData()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    func reloadData() {
        dispatch.asynchronous(updateQueue) {
            self.model = CollectionUIModel(ApplicationServiceRegistry.walletService.grouppedTransactions())
        }.then(.main, closure: displayUpdatedData)
    }

    func displayUpdatedData() {
        tableView.reloadData()
        tableView.backgroundView = model.isEmpty ? emptyView : nil
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MainTrackingEvent.transactions)
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

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let transaction = model[indexPath] else { return }
        delegate?.didSelectTransaction(id: transaction.id)
    }

    // MARK: EventSubscriber

    public func notify() {
        reloadData()
    }

}
