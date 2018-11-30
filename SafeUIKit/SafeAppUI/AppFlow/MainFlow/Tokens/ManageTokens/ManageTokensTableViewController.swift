//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common

protocol ManageTokensTableViewControllerDelegate: class {
    func addToken()
    func rearrange(tokens: [TokenData])
    func hide(token: TokenData)
}

extension Array {

    mutating func rearrange(from: Int, to: Int) {
        guard from != to else { return }
        precondition(indices.contains(from) && indices.contains(to), "invalid indexes")
        insert(remove(at: from), at: to)
    }

}

final class ManageTokensTableViewController: UITableViewController {

    weak var delegate: ManageTokensTableViewControllerDelegate?

    private var tokens = [TokenData]()

    private enum Strings {
        static let title = LocalizedString("manage_tokens.title",
                                           comment: "Title for Manage Tokens Screen.")
        static let hide = LocalizedString("manage_tokens.hide", comment: "Hide displayed token action.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title
        navigationItem.rightBarButtonItem = editButtonItem

        let bundle = Bundle(for: TokenBalanceTableViewCell.self)
        tableView.register(UINib(nibName: "TokenBalanceTableViewCell", bundle: bundle),
                           forCellReuseIdentifier: "TokenBalanceTableViewCell")
        tableView.estimatedRowHeight = TokenBalanceTableViewCell.height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundView = BackgroundImageView(frame: tableView.frame)

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToken))
        navigationItem.setLeftBarButton(addButton, animated: false)
        setEditing(true, animated: false)
        reloadData()
    }

    func reloadData(delay: TimeInterval = 0.1) {
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            Timer.wait(delay)
            self.tokens = ApplicationServiceRegistry.walletService.visibleTokens(withEth: false)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @objc internal func addToken() {
        delegate?.addToken()
    }

    func tokenAdded() {
        reloadData()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing {
            super.setEditing(editing, animated: animated)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TokenBalanceTableViewCell", for: indexPath) as! TokenBalanceTableViewCell
        cell.configure(tokenData: tokens[indexPath.row])
        cell.displayBalance = false
        return cell
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        guard sourceIndexPath.row != destinationIndexPath.row else { return }
        var newTokens = tokens
        newTokens.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
        delegate?.rearrange(tokens: newTokens)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        delegate?.hide(token: tokens[indexPath.row])
        reloadData()
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView,
                            titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return Strings.hide
    }

}
