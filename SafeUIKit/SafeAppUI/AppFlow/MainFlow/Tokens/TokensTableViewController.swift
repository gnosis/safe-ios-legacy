//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

final class TokensTableViewController: UITableViewController, EventSubscriber {

    private var tokens = [TokenData]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let bundle = Bundle(for: TokensTableViewController.self)
        tableView.register(UINib(nibName: "AddTokenFooterView", bundle: bundle),
                           forHeaderFooterViewReuseIdentifier: "AddTokenFooterView")
        tableView.register(UINib(nibName: "TokenBalanceTableViewCell", bundle: bundle),
                           forCellReuseIdentifier: "TokenBalanceTableViewCell")
        tableView.estimatedRowHeight = TokenBalanceTableViewCell.height
        tableView.rowHeight = UITableViewAutomaticDimension

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(update), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.backgroundColor = ColorName.paleGreyThree.color

        update()
    }

    @objc private func update() {
        DispatchQueue.global().async {
            ApplicationServiceRegistry.walletService.syncBalances(subscriber: self)
        }
    }

    func notify() {
        tokens = ApplicationServiceRegistry.walletService.visibleTokens(withEth: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenBalanceTableViewCell",
                                                 for: indexPath) as! TokenBalanceTableViewCell
        cell.configure(tokenData: tokens[indexPath.row])
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddTokenFooterView")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return AddTokenFooterView.height
    }

}
