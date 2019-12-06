//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common
import MultisigWalletApplication

class WCBatchTransactionsTableViewController: UITableViewController {

    let emptyView = EmptyResultsView()

    var transactions: [TransactionData] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.displayUpdatedData()
            }
        }
    }

    func displayUpdatedData() {
        tableView?.reloadData()
        tableView?.backgroundView = transactions.isEmpty ? emptyView : nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView.text = LocalizedString("empty_safe_transactions_message", comment: "No transactions yet")
        title = LocalizedString("batched_transactions", comment: "Transactions")
        tableView.register(UINib(nibName: "TransactionTableViewCell",
                                 bundle: Bundle(for: TransactionTableViewCell.self)),
                           forCellReuseIdentifier: "TransactionTableViewCell")
        tableView.allowsSelection = false
        tableView.rowHeight = 70
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.separatorStyle = .none
        displayUpdatedData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCustomBackButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(WCTrackingEvent.batched)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < transactions.count else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell")
            as! TransactionTableViewCell
        cell.configure(transaction: transactions[indexPath.row])
        cell.accessoryType = .none
        return cell
    }

}
