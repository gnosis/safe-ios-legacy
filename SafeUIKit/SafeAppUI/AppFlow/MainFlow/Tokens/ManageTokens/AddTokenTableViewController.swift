//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

protocol AddTokenTableViewControllerDelegate: class {
    func didSelectToken(_ tokenData: TokenData)
}

class AddTokenTableViewController: UITableViewController {

    weak var delegate: AddTokenTableViewControllerDelegate!

    let searchController = UISearchController(searchResultsController: nil)

    private let tokens = ApplicationServiceRegistry.walletService.tokens() // already sorted
    private var sectionedTokens = [String: [TokenData]]()
    private var filteredTokens = [TokenData]() {
        didSet {
            sectionedTokens = [:]
            filteredTokens.forEach {
                let sectionTitle = String($0.code.first!).uppercased()
                if sectionedTokens[sectionTitle] != nil {
                    sectionedTokens[sectionTitle]!.append($0)
                } else {
                    sectionedTokens[sectionTitle] = [$0]
                }
            }
            sectionTokensTitles = [String](sectionedTokens.keys).sorted()
            tableView.reloadData()
        }
    }
    private var sectionTokensTitles = [String]()

    private enum Strings {
        static let title = LocalizedString("add_token.title", comment: "Title for Add Token screen.")
    }

    static func create(delegate: AddTokenTableViewControllerDelegate) -> UINavigationController {
        let navControllet = StoryboardScene.Main.addTokenNavigationController.instantiate()
        let controller = navControllet.childViewControllers[0] as! AddTokenTableViewController
        controller.delegate = delegate
        return navControllet
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
        tableView.sectionIndexMinimumDisplayRowCount = 15
        tableView.tableFooterView = UIView()
        let bundle = Bundle(for: TokenBalanceTableViewCell.self)
        tableView.register(UINib(nibName: "TokenBalanceTableViewCell", bundle: bundle),
                           forCellReuseIdentifier: "TokenBalanceTableViewCell")
        tableView.estimatedRowHeight = TokenBalanceTableViewCell.height
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTokensTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionedTokens[sectionTokensTitles[section]]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenBalanceTableViewCell",
                                                 for: indexPath) as! TokenBalanceTableViewCell
        cell.configure(tokenData: token(for: indexPath), withBalance: false, withTokenName: true)
        return cell
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTokensTitles
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTokensTitles[section]
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.didSelectToken(token(for: indexPath))
    }

    private func token(for indexPath: IndexPath) -> TokenData {
        return sectionedTokens[sectionTokensTitles[indexPath.section]]![indexPath.row]
    }

}

extension AddTokenTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased(), !text.isEmpty else {
            filteredTokens = tokens
            return
        }
        filteredTokens = tokens.filter {
            $0.code.lowercased().contains(text) || $0.name.lowercased().contains(text)
        }
    }

}

extension AddTokenTableViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: false)
    }

}
