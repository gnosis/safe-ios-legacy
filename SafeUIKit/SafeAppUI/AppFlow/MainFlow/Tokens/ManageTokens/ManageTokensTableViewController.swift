//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

protocol ManageTokensTableViewControllerDelegate: class {
    func addToken()
    func endEditing(tokens: [TokenData])
}

extension Array {

    mutating func rearrange(from: Int, to: Int) {
        precondition(from != to && indices.contains(from) && indices.contains(to), "invalid indexes")
        insert(remove(at: from), at: to)
    }

}

class ManageTokensTableViewController: UITableViewController {

    weak var delegate: ManageTokensTableViewControllerDelegate?

    private var tokens = ApplicationServiceRegistry.walletService.visibleTokens(withEth: false)

    private enum Strings {
        static let title = LocalizedString("manage_tokens.title",
                                           comment: "Title for Manage Tokens Screen.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title
        navigationItem.rightBarButtonItem = editButtonItem

        let bundle = Bundle(for: TokenBalanceTableViewCell.self)
        tableView.register(UINib(nibName: "TokenBalanceTableViewCell", bundle: bundle),
                           forCellReuseIdentifier: "TokenBalanceTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = TokenBalanceTableViewCell.height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = ColorName.paleGreyThree.color

    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if isEditing {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToken))
            navigationItem.setLeftBarButton(addButton, animated: animated)
        } else {
            navigationItem.setLeftBarButton(nil, animated: animated)
            delegate?.endEditing(tokens: tokens)
        }
    }

    @objc internal func addToken() {
        delegate?.addToken()
    }

    func tokenAdded(tokenData: TokenData) {
        tokens.append(tokenData)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TokenBalanceTableViewCell", for: indexPath) as! TokenBalanceTableViewCell
        cell.configure(tokenData: tokens[indexPath.row], withBalance: false)
        return cell
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        tokens.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

}
