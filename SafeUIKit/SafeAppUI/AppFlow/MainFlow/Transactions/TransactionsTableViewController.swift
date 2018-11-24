//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BlockiesSwift
import MultisigWalletApplication

public protocol TransactionsTableViewControllerDelegate: class {
    func didSelectTransaction(id: String)
}

public class TransactionsTableViewController: UITableViewController {

    private var groups = [TransactionGroupData]()
    public weak var delegate: TransactionsTableViewControllerDelegate?
    let emptyView = TransactionsEmptyView()
    let headerHeight: CGFloat = 34
    let footerHeight: CGFloat = ShadowFooterView.height
    let rowHeight: CGFloat = 70

    public static func create() -> TransactionsTableViewController {
        return StoryboardScene.Main.transactionsTableViewController.instantiate()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TransactionsGroupHeaderView",
                                 bundle: Bundle(for: TransactionsGroupHeaderView.self)),
                           forHeaderFooterViewReuseIdentifier: "TransactionsGroupHeaderView")
        tableView.register(ShadowFooterView.self, forHeaderFooterViewReuseIdentifier: "ShadowFooterView")
        tableView.sectionHeaderHeight = headerHeight
        tableView.sectionFooterHeight = footerHeight
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
        DispatchQueue.global().async {
            self.groups = ApplicationServiceRegistry.walletService.grouppedTransactions()
            DispatchQueue.main.async {
                self.displayUpdatedData()
            }
        }
    }

    private func displayUpdatedData() {
        tableView.reloadData()
        tableView.backgroundView = groups.isEmpty ? emptyView : nil
    }

    // MARK: - Table view data source

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].transactions.count
    }

    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TransactionsGroupHeaderView")
            as! TransactionsGroupHeaderView
        view.configure(group: groups[section])
        return view
    }

    public override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "ShadowFooterView")
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell",
                                                 for: indexPath) as! TransactionTableViewCell
        cell.configure(transaction: groups[indexPath.section].transactions[indexPath.row])
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectTransaction(id: groups[indexPath.section].transactions[indexPath.row].id)
    }

}

extension TransactionsTableViewController: EventSubscriber {

    public func notify() {
        reloadData()
    }

}
