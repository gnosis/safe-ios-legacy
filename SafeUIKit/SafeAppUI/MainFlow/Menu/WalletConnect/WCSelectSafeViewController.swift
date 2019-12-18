//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

class WCSelectSafeViewController: UITableViewController {

    var safes = [WalletData]()
    var nextButton: UIBarButtonItem!
    var onNext: (() -> Void)?

    var walletService: WalletApplicationService {
        return ApplicationServiceRegistry.walletService
    }

    enum Strings {
        static let title = "WalletConnect"
        static let header = LocalizedString("select_safe_to_connect", comment: "Select Safe to connect")
        static let next = LocalizedString("next", comment: "Next")
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
        trackEvent(WCTrackingEvent.selectSafe)
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
    }

    private func update() {
        safes = walletService.wallets().filter { $0.state == .readyToUse }
        tableView.reloadData()
        nextButton.isEnabled = safes.contains { $0.isSelected }
    }

    @objc private func onNextPressed() {
        onNext?()
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
           ApplicationServiceRegistry.walletService.selectWallet(safes[indexPath.row].id)
           update()
       }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BackgroundHeaderFooterView")
            as! BackgroundHeaderFooterView
        view.title = Strings.header
        return view
    }

}
