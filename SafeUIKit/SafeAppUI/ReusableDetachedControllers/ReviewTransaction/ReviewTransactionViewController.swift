//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

final class ReviewTransactionViewController: UITableViewController {

    private var tx: TransactionData!

    enum Strings {
        static let outgoingTransfer = LocalizedString("transaction.outgoing_transfer", comment: "Outgoing transafer")
    }

    convenience init(transactionID: String) {
        self.init()
        tx = ApplicationServiceRegistry.walletService.transactionData(transactionID)!
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    private func configureTableView() {
        tableView.register(TransactionHeaderCell.self, forCellReuseIdentifier: "TransactionHeaderCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundView = BackgroundImageView(frame: tableView.frame)
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
    }

}

// MARK: - Table view data source

extension ReviewTransactionViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHeaderCell",
                                                 for: indexPath) as! TransactionHeaderCell
        let imageURL: URL? = tx.tokenLogoUrl.isEmpty ? nil : URL(string: tx.tokenLogoUrl)!
        cell.configure(imageURL: imageURL, code: tx.token, info: Strings.outgoingTransfer)
        return cell
    }

}
