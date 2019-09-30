//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Common

protocol SwitchSafesTableViewControllerDelegate: class {
    func switchSafesTableViewController(_ controller: SwitchSafesTableViewController, didSelect wallet: WalletData)
    func switchSafesTableViewController(_ controller: SwitchSafesTableViewController,
                                        didRequestToRemove wallet: WalletData)
    func switchSafesTableViewControllerDidFinish(_ controller: SwitchSafesTableViewController)
}

class SwitchSafesTableViewController: UITableViewController {

    weak var delegate: SwitchSafesTableViewControllerDelegate?
    var safes = [WalletData]()
    var backButtonItem: UIBarButtonItem!

    var walletService: WalletApplicationService {
        return ApplicationServiceRegistry.walletService
    }

    enum Strings {
        static let title = LocalizedString("switch_safes", comment: "Switch Safes")
        static let remove = LocalizedString("remove", comment: "Remove")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(SafesTrackingEvent.switchSafes)
    }

    override func willMove(toParent parent: UIViewController?) {
        backButtonItem = UIBarButtonItem.backButton(target: self, action: #selector(back))
        setCustomBackButton(backButtonItem)
    }

    @objc func back() {
        delegate?.switchSafesTableViewControllerDidFinish(self)
    }

    private func configureNavigationBar() {
        title = Strings.title
        navigationItem.rightBarButtonItem = editButtonItem
    }

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

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.switchSafesTableViewController(self, didSelect: safes[indexPath.row])
        update()
    }

    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        delegate?.switchSafesTableViewController(self, didRequestToRemove: safes[indexPath.row])
    }

    override func tableView(_ tableView: UITableView,
                            titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return Strings.remove
    }

}

extension SwitchSafesFlowCoordinator: InteractivePopGestureResponder {

    func interactivePopGestureShouldBegin() -> Bool {
        return false
    }

}
