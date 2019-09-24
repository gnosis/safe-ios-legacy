//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Common

protocol SwitchSafesTableViewControllerDelegate: class {
    func didSelect(wallet: WalletData)
}

class SwitchSafesTableViewController: UITableViewController {

    weak var delegate: SwitchSafesTableViewControllerDelegate?
    var safes = [WalletData]()

    var walletService: WalletApplicationService {
        return ApplicationServiceRegistry.walletService
    }

    enum Strings {
        static let title = LocalizedString("switch_safes", comment: "Switch Safes")
        static let edit = LocalizedString("edit", comment: "Edit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        update()
    }

    private func configureNavigationBar() {
        title = Strings.title
        let editButtonItem = UIBarButtonItem(title: Strings.edit, style: .done, target: self, action: #selector(edit))
        navigationItem.rightBarButtonItem = editButtonItem
    }

    @objc private func edit() {}

    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = ColorName.white.color
        tableView.register(UINib(nibName: "SwitchSafesTableViewCell",
                                 bundle: Bundle(for: SwitchSafesTableViewCell.self)),
                           forCellReuseIdentifier: "SwitchSafesTableViewCell")
    }

    private func update() {
        safes = walletService.wallets()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return safes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchSafesTableViewCell",
                                                 for: indexPath) as! SwitchSafesTableViewCell
        let data = safes[indexPath.row]
        cell.configure(walletData: data)
        cell.accessoryView = data.address == walletService.selectedWalletAddress ? checkmarkImageView() : nil
        return cell
    }

    private func checkmarkImageView() -> UIImageView {
        let checkmarkImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 13))
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.image = Asset.checkmark.image
        return checkmarkImageView
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(wallet: safes[indexPath.row])
        update()
    }

}
