//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

final class TokensTableViewController: UITableViewController {

    private var tokens = [TokenData]()

    static func create() -> TokensTableViewController {
        return StoryboardScene.Main.tokensTableViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "AddTokenFooterView",
                                 bundle: Bundle(for: AddTokenFooterView.self)),
                           forHeaderFooterViewReuseIdentifier: "AddTokenFooterView")
        tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        let refreshControl = UIRefreshControl()
        refreshControl.bounds = CGRect(x: refreshControl.bounds.origin.x,
                                       y: refreshControl.bounds.origin.y + 35,
                                       width: refreshControl.bounds.size.width,
                                       height: refreshControl.bounds.size.height)
        refreshControl.addTarget(self, action: #selector(update), for: .valueChanged)
        tableView.refreshControl = refreshControl
        update()
    }

    @objc private func update() {
        tokens = ApplicationServiceRegistry.walletService.tokens()
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddTokenFooterView")
    }

}
