//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

public class TokensTableViewController: UITableViewController {

    private var tokens = [TokenData]()

    public static func create() -> TokensTableViewController {
        return StoryboardScene.Main.tokensTableViewController.instantiate()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "AddTokenFooterView",
                                 bundle: Bundle(for: AddTokenFooterView.self)),
                           forHeaderFooterViewReuseIdentifier: "AddTokenFooterView")
        tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        update()
    }

    private func update() {
        tokens = ApplicationServiceRegistry.walletService.tokens()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenBalanceTableViewCell",
                                                 for: indexPath) as! TokenBalanceTableViewCell
        cell.configure(tokenData: tokens[indexPath.row])
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    public override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddTokenFooterView")
    }

}
