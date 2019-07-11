//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

final class WCSessionListTableViewController: UITableViewController {

    var scanButtonItem: ScanBarButtonItem!
    let noSessionsView = EmptyResultsView()

    var wcService: WalletConnectApplicationService {
        return ApplicationServiceRegistry.walletConnectService
    }

    enum Strings {
        static let title = LocalizedString("walletconnect", comment: "WalletConnect")
        static let scan = LocalizedString("scan", comment: "Scan")
        static let activeSessions = LocalizedString("active_sessions", comment: "Active sessions").uppercased()
        static let disconnect = LocalizedString("disconnect", comment: "Disconnect")
        static let noActiveSessions = LocalizedString("no_active_sessions", comment: "No active sessions")
    }

    private var sessions = [WCSessionData]()
    private var isRequestingNetwork = false {
        didSet {
            updateLoading()
        }
    }

    init() {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        subscribeForSessionUpdates()
        update()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(WCTrackingEvent.sessionList)
    }

    private func configureNavigationBar() {
        title = Strings.title
        scanButtonItem = ScanBarButtonItem(title: Strings.scan)
        scanButtonItem.delegate = self
        scanButtonItem.scanValidatedConverter = { code in
            guard code.starts(with: "wc:") else { return nil }
            return code
        }
        navigationItem.rightBarButtonItem = scanButtonItem
    }

    private func configureTableView() {
        noSessionsView.text = Strings.noActiveSessions
        noSessionsView.centerPadding = view.frame.height / 4
        tableView.rowHeight = BasicTableViewCell.titleAndSubtitleHeight
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = ColorName.paleGrey.color
        tableView.register(UINib(nibName: "BasicTableViewCell", bundle: Bundle(for: BasicTableViewCell.self)),
                           forCellReuseIdentifier: "BasicTableViewCell")
        tableView.register(BackgroundHeaderFooterView.self,
                           forHeaderFooterViewReuseIdentifier: "BackgroundHeaderFooterView")
    }

    private func subscribeForSessionUpdates() {
        wcService.subscribeForSessionUpdates(self)
    }

    private func update() {
        sessions = wcService.sessions()
        DispatchQueue.main.async {
            self.isRequestingNetwork = false
            self.tableView.backgroundView = self.sessions.isEmpty ? self.noSessionsView : nil
            self.tableView.reloadData()
        }
    }

    private func updateLoading() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async(execute: updateLoading)
            return
        }
        if isRequestingNetwork {
            scanButtonItem.isEnabled = false
            navigationItem.titleView = LoadingTitleView()
        } else {
            scanButtonItem.isEnabled = true
            navigationItem.titleView = nil
        }
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

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // TODO: clarify with product one more time if we should display this alert at all.
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        showDisconnectAlert(for: indexPath, withTitle: true)
    }

    private func showDisconnectAlert(for indexPath: IndexPath, withTitle: Bool) {
        let session = sessions[indexPath.row]
        let alert = UIAlertController
            .disconnectWCSession(sessionName: session.title, withTitle: withTitle) { [unowned self] in
                self.isRequestingNetwork = true
                try? self.wcService.disconnect(sessionID: session.id)
        }
        present(alert, animated: true)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showDisconnectAlert(for: indexPath, withTitle: false)
    }

    override func tableView(_ tableView: UITableView,
                            titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return Strings.disconnect
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !sessions.isEmpty else { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BackgroundHeaderFooterView")
            as! BackgroundHeaderFooterView
        view.title = Strings.activeSessions
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sessions.isEmpty ? 0 : BackgroundHeaderFooterView.height
    }

}

extension WCSessionListTableViewController: ScanBarButtonItemDelegate {

    func scanBarButtonItemWantsToPresentController(_ controller: UIViewController) {
        present(controller, animated: true)
        self.trackEvent(WCTrackingEvent.scan)
    }

    func scanBarButtonItemDidScanValidCode(_ code: String) {
        do {
            isRequestingNetwork = true
            try wcService.connect(url: code)
        } catch {
            present(UIAlertController.failedToConnectWCUrl(), animated: true)
        }
    }

}

extension WCSessionListTableViewController: EventSubscriber {

    // FailedToConnectSession, SessionUpdated (connected/disconnected/-reconnecting?-)
    func notify() {
        update()
    }

}
