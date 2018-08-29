//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class AddTokenTableViewController: UITableViewController {

    let searchController = UISearchController(searchResultsController: nil)

    private let tokens = ApplicationServiceRegistry.walletService.tokens()
    private var filteredTokens = [TokenData]()

    private enum Strings {
        static let title = LocalizedString("add_token.title", comment: "Title for Add Token screen.")
    }

    static func create() -> UINavigationController {
        return StoryboardScene.Main.addTokenNavigationController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationItem()
        configureSearchController()
        configureTableView()

        filteredTokens = tokens
    }

    private func configureNavigationItem() {
        title = Strings.title
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func configureSearchController() {
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = .prominent
    }

    private func configureTableView() {
        tableView.sectionIndexMinimumDisplayRowCount = 20
        tableView.tableFooterView = UIView()

        let bundle = Bundle(for: TokenBalanceTableViewCell.self)
        tableView.register(UINib(nibName: "TokenBalanceTableViewCell", bundle: bundle),
                           forCellReuseIdentifier: "TokenBalanceTableViewCell")
        tableView.estimatedRowHeight = TokenBalanceTableViewCell.height
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTokens.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenBalanceTableViewCell",
                                                 for: indexPath) as! TokenBalanceTableViewCell
        cell.configure(tokenData: filteredTokens[indexPath.row], withBalance: false, withTokenName: true)
        return cell
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let availableIndexes = Set(tokens.map { String($0.code.first!).uppercased() })
            .union(Set(tokens.map { String($0.name.first!).uppercased() }))
        return Array(availableIndexes).sorted()
    }

}

extension AddTokenTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased(), text != "" else {
            filteredTokens = tokens
            return
        }
        filteredTokens = tokens.filter {
            $0.code.lowercased().contains(text) || $0.name.lowercased().contains(text)
        }
        tableView.reloadData()
    }

}

extension AddTokenTableViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true)
    }

}
