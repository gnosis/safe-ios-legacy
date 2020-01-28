//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol LoadMultisigSelectTableViewControllerDelegate: class {
    func loadMultisigSelectTableViewController(controller: LoadMultisigSelectTableViewController,
                                               didSelectSafes safes: [WalletData])
}

class LoadMultisigSelectTableViewController: UITableViewController {

    var safes = [WalletData]()
    var nextButton: UIBarButtonItem!

    weak var delegate: LoadMultisigSelectTableViewControllerDelegate?

    private let emptyView = EmptyResultsView()

    enum Strings {
        static let title = "Load Multisig"
        static let header = "Found Multisig Safes"
        static let noSafesFound = "No Multisig Safes found where selected Safe is an owner."
        static let next = LocalizedString("next", comment: "Next")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        emptyView.text = Strings.noSafesFound
        emptyView.centerPadding = 120
        configureNavigationBar()
        configureTableView()
        loadData()
    }

    private func configureNavigationBar() {
        title = Strings.title
        nextButton = UIBarButtonItem(title: Strings.next, style: .plain, target: self, action: #selector(onNextPressed))
        navigationItem.rightBarButtonItem = nextButton
    }

    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = BackgroundHeaderFooterView.height
        tableView.backgroundColor = ColorName.white.color
        tableView.register(BackgroundHeaderFooterView.self,
                           forHeaderFooterViewReuseIdentifier: "BackgroundHeaderFooterView")
        tableView.register(UINib(nibName: "SwitchSafesTableViewCell",
                                 bundle: Bundle(for: SwitchSafesTableViewCell.self)),
                           forCellReuseIdentifier: "SwitchSafesTableViewCell")

        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }

    @objc private func loadData() {
        DispatchQueue.global.async { [weak self] in
            self?.safes = ApplicationServiceRegistry.walletService.findMultisigSafesForSelectedSafe()
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
                self?.update()
            }
        }
    }

    private func update() {
        tableView.reloadData()
        tableView.backgroundView = safes.isEmpty ? emptyView : nil
        nextButton.isEnabled = safes.contains { $0.isSelected }
    }

    @objc private func onNextPressed() {
        delegate?.loadMultisigSelectTableViewController(controller: self, didSelectSafes: safes)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return safes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchSafesTableViewCell",
                                                 for: indexPath) as! SwitchSafesTableViewCell
        let safe = safes[indexPath.row]
        cell.configure(walletData: safe)
        cell.accessoryView = safe.isSelected ? checkmarkImageView() : nil
        return cell
    }

    private func checkmarkImageView() -> UIImageView {
        let checkmarkImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 13))
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.image = Asset.checkmark.image
        return checkmarkImageView
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let safe = safes[indexPath.row]
        safes[indexPath.row] = safe.withSelected(!safe.isSelected)
        update()
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BackgroundHeaderFooterView")
            as! BackgroundHeaderFooterView
        view.title = safes.isEmpty ? "" : Strings.header
        return view
    }

}

fileprivate extension WalletData {

    func withSelected(_ selected: Bool) -> WalletData {
        return WalletData(id: self.id,
                          address: self.address,
                          name: self.name,
                          state: self.state,
                          canRemove: self.canRemove,
                          isSelected: selected,
                          requiresBackupToRemove: self.requiresBackupToRemove,
                          isMultisig: self.isMultisig,
                          isReadOnly: self.isReadOnly)
    }

}
