//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

protocol MockSessionData {}

final class WCSessionListViewController: UITableViewController {

    var scanButtonItem: UIBarButtonItem!
    let noSessionsView = EmptyResultsView()

    enum Strings {
        static let title = LocalizedString("walletconnect", comment: "WalletConnect")
        static let scan = LocalizedString("scan", comment: "Scan")
        static let activeSessions = LocalizedString("active_sessions", comment: "Active sessions")
        static let disconnect = LocalizedString("disconnect", comment: "Disconnect")
        static let noActiveSessions = LocalizedString("no_active_sessions", comment: "No active sessions")
    }

    var sessions = [MockSessionData]() {
        didSet {
            DispatchQueue.main.async {
                self.update()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title
        noSessionsView.text = Strings.noActiveSessions
        noSessionsView.centerPadding = view.frame.height / 4
        scanButtonItem = UIBarButtonItem(title: Strings.scan, style: .done, target: self, action: #selector(scan))
        navigationItem.rightBarButtonItem = scanButtonItem
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = ColorName.paleGrey.color
        update()
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
        return UITableViewCell()
    }

}
