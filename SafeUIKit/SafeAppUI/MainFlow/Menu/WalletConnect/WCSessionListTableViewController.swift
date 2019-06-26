//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol WCSessionData {
    var image: UIImage { get }
    var title: String { get }
    var subtitle: String { get }
}

final class WCSessionListTableViewController: UITableViewController {

    var scanButtonItem: UIBarButtonItem!
    let noSessionsView = EmptyResultsView()

    enum Strings {
        static let title = LocalizedString("walletconnect", comment: "WalletConnect")
        static let scan = LocalizedString("scan", comment: "Scan")
        static let activeSessions = LocalizedString("active_sessions", comment: "Active sessions")
        static let disconnect = LocalizedString("disconnect", comment: "Disconnect")
        static let noActiveSessions = LocalizedString("no_active_sessions", comment: "No active sessions")
    }

    var sessions = [WCSessionData]() {
        didSet {
            DispatchQueue.main.async {
                self.update()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        update()
    }

    private func configureNavigationBar() {
        title = Strings.title
        scanButtonItem = UIBarButtonItem(title: Strings.scan, style: .done, target: self, action: #selector(scan))
        navigationItem.rightBarButtonItem = scanButtonItem
    }

    private func configureTableView() {
        noSessionsView.text = Strings.noActiveSessions
        noSessionsView.centerPadding = view.frame.height / 4
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = ColorName.paleGrey.color
        tableView.register(UINib(nibName: "BasicTableViewCell", bundle: Bundle(for: BasicTableViewCell.self)),
                           forCellReuseIdentifier: "BasicTableViewCell")
    }

    @objc private func scan() {}

    private func update() {
        tableView.backgroundView = sessions.isEmpty ? noSessionsView : nil
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableViewCell",
                                                 for: indexPath) as! BasicTableViewCell
        cell.configure(wcSessionData: sessions[indexPath.row])
        return cell
    }

}
