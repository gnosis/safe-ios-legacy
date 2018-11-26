//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common

final class TokensTableViewController: UITableViewController {

    weak var delegate: MainViewControllerDelegate?

    typealias Section = (
        headerViewIdentifier: String?,
        headerHeight: CGFloat,
        footerViewIdentifier: String?,
        footerHeight: CGFloat,
        elements: [TokenData]
    )

    private var tokens = [TokenData]() {
        didSet {
            configureSections(tokens)
        }
    }

    private var sections = [Section]()

    private func configureSections(_ tokens: [TokenData]) {
        sections = []
        guard !tokens.isEmpty else {
            return
        }
        // Eth section
        sections.append((
            headerViewIdentifier: nil,
            headerHeight: 0,
            footerViewIdentifier: "EmptyFooter",
            footerHeight: 16,
            elements: [tokens.first!]
        ))
        // Tokens section
        let shouldShowTokensFooter = tokens.count == 1
        sections.append((
            headerViewIdentifier: "TokensHeaderView",
            headerHeight: TokensHeaderView.height,
            footerViewIdentifier: shouldShowTokensFooter ? "AddTokenFooterView" : nil,
            footerHeight: shouldShowTokensFooter ? AddTokenFooterView.height : 0,
            elements: [TokenData](tokens.dropFirst())
        ))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let bundle = Bundle(for: TokensTableViewController.self)
        tableView.register(UINib(nibName: "AddTokenFooterView", bundle: bundle),
                           forHeaderFooterViewReuseIdentifier: "AddTokenFooterView")
        tableView.register(UINib(nibName: "TokensHeaderView", bundle: bundle),
                           forHeaderFooterViewReuseIdentifier: "TokensHeaderView")
        tableView.register(EmptyFooter.self, forHeaderFooterViewReuseIdentifier: "EmptyFooter")
        tableView.register(UINib(nibName: "TokenBalanceTableViewCell",
                                 bundle: Bundle(for: TokenBalanceTableViewCell.self)),
                           forCellReuseIdentifier: "TokenBalanceTableViewCell")
        tableView.estimatedRowHeight = TokenBalanceTableViewCell.height
        tableView.rowHeight = UITableView.automaticDimension

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(update), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()

        ApplicationServiceRegistry.walletService.subscribeOnTokensUpdates(subscriber: self)

        update()
        notify()
    }

    @objc private func update() {
        DispatchQueue.global().async {
            ApplicationServiceRegistry.walletService.syncBalances()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenBalanceTableViewCell",
                                                 for: indexPath) as! TokenBalanceTableViewCell
        cell.configure(tokenData: tokenData(for: indexPath))
        cell.displayName = .nameOnly
        cell.withDisclosure = true
        return cell
    }

    private func tokenData(for indexPath: IndexPath) -> TokenData {
        return sections[indexPath.section].elements[indexPath.row]
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let identifier = sections[section].headerViewIdentifier else { return nil }
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let identifier = sections[section].footerViewIdentifier else { return nil }
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.createNewTransaction(token: tokenData(for: indexPath).address)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].headerHeight
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections[section].footerHeight
    }

}

extension TokensTableViewController: EventSubscriber {

    func notify() {
        tokens = ApplicationServiceRegistry.walletService.visibleTokens(withEth: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    private class EmptyFooter: UITableViewHeaderFooterView {

        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            backgroundView = UIView()
            backgroundView?.backgroundColor = .white
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

    }

}
