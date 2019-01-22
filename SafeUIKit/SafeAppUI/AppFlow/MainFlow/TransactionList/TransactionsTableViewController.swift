//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BlockiesSwift
import MultisigWalletApplication
import Common

public protocol TransactionsTableViewControllerDelegate: class {
    func didSelectTransaction(id: String)
}

public class TransactionsTableViewController: UITableViewController, EventSubscriber {

    private var groups = TransactionGroupList()
    public weak var delegate: TransactionsTableViewControllerDelegate?
    let emptyView = TransactionsEmptyView()
    let rowHeight: CGFloat = 70
    private let updateQueue = DispatchQueue(label: "TransactionDetailsUpdateQueue",
                                            qos: .userInitiated,
                                            attributes: [])

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
            self.groups = TransactionGroupList(ApplicationServiceRegistry.walletService.grouppedTransactions())
        }.then(.main, closure: displayUpdatedData)
    }

    func displayUpdatedData() {
        tableView.reloadData()
        tableView.backgroundView = groups.isEmpty ? emptyView : nil
    }

    // MARK: - Table view data source

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return groups.sectionCount
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.itemCount(section: section)
    }

    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let group = groups[section] else { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TransactionsGroupHeaderView")
            as! TransactionsGroupHeaderView
        view.configure(group: group)
        return view
    }

    // why crashing?
    //  because index out of range (groups / transactions)
    // why out of range?
    //  [hypothesis] because groups were updated while or before tableview reload finished
    // why groups updated before tableview finished reload?
    //  [hypothesis] because async reload came several times and the groups update happened faster than UI update
    // why groups async update was faster than UI updates?
    //  [hypothesis] because UI and model async updates were not sequenced

    // cause: reloadTable() and cellForRow are not happening synchronously, rather, in different run loop cycles!
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let transaction = groups[indexPath] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell",
                                                 for: indexPath) as! TransactionTableViewCell
        cell.configure(transaction: transaction)
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let transaction = groups[indexPath] else { return }
        delegate?.didSelectTransaction(id: transaction.id)
    }

    // MARK: EventSubscriber

    public func notify() {
        reloadData()
    }

}

struct TransactionGroupList {

    private var groups: [TransactionGroupData]

    init(_ groups: [TransactionGroupData] = []) {
        self.groups = groups
    }

    var isEmpty: Bool {
        return groups.isEmpty
    }

    var sectionCount: Int {
        return groups.count
    }

    func itemCount(section: Int) -> Int {
        return self[section]?.transactions.count ?? 0
    }

    subscript(indexPath: IndexPath) -> TransactionData? {
        guard isWithinBounds(indexPath: indexPath) else { return nil }
        return groups[indexPath.section].transactions[indexPath.row]
    }

    subscript(section: Int) -> TransactionGroupData? {
        guard isWithinBounds(section: section) else { return nil }
        return groups[section]
    }

    private func isWithinBounds(indexPath: IndexPath) -> Bool {
        return isWithinBounds(section: indexPath.section) &&
            indexPath.row < groups[indexPath.section].transactions.count
    }

    private func isWithinBounds(section: Int) -> Bool {
        return section < groups.count
    }

}
