//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

 class WCSessionListTableViewController: UITableViewController {

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
        static let qrScannerHeader = LocalizedString("scan_wallet_connect", comment: "Scan WalletConnect QR code")
    }

    private var sessions = [WCSessionData]()

    /// The WalletConnect url to connect to when the screen will load.
    private (set) var connectionURL: URL?

    init() {
        super.init(style: .grouped)
    }

    init(connectionURL: URL?) {
        super.init(style: .grouped)
        self.connectionURL = connectionURL
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
        if let url = connectionURL {
            scanBarButtonItemDidScanValidCode(url.absoluteString)
        }
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
        scanButtonItem.scanHeader = Strings.qrScannerHeader
        navigationItem.rightBarButtonItem = scanButtonItem
    }

    private func configureTableView() {
        noSessionsView.text = Strings.noActiveSessions
        noSessionsView.centerPadding = view.frame.height / 4
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = ColorName.white.color
        tableView.register(UINib(nibName: "WCSessionListCell", bundle: Bundle(for: WCSessionListCell.self)),
                           forCellReuseIdentifier: "WCSessionListCell")
        tableView.register(BackgroundHeaderFooterView.self,
                           forHeaderFooterViewReuseIdentifier: "BackgroundHeaderFooterView")
    }

    func scan() {
        scanButtonItem?.scan()
    }

    private func subscribeForSessionUpdates() {
        wcService.subscribeForSessionUpdates(self)
    }

    private func update() {
        sessions = wcService.sessions()
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.tableView.backgroundView = self.sessions.isEmpty ? self.noSessionsView : nil
            self.tableView.reloadData()
        }
    }

    private func showCompletionPanel() {
        let shouldShowPanel = didConnectNewSessions(in: wcService.sessions())
        guard shouldShowPanel else { return }
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let vc = WCCompletionPanelViewController.create()
            vc.present(from: self)
        }
    }

    private func didConnectNewSessions(in newSessions: [WCSessionData]) -> Bool {
        let oldIDs = sessions.filter { !$0.isConnecting }.map { $0.id }
        let newIDs = newSessions.filter { !$0.isConnecting }.map { $0.id }
        let hasNewIDs = !Set(newIDs).subtracting(oldIDs).isEmpty
        return hasNewIDs
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WCSessionListCell",
                                                 for: indexPath) as! WCSessionListCell
        cell.configure(wcSessionData: sessions[indexPath.row], screen: .sessions)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        showDisconnectAlert(for: indexPath, withTitle: true)
    }

    private func showDisconnectAlert(for indexPath: IndexPath, withTitle: Bool) {
        let session = sessions[indexPath.row]
        let alert = UIAlertController
            .disconnectWCSession(sessionName: session.title, withTitle: withTitle) { [unowned self] in
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
            try wcService.connect(url: code)
        } catch {
            present(UIAlertController.failedToConnectWCUrl(), animated: true)
        }
    }

}

extension WCSessionListTableViewController: EventSubscriber {

    // FailedToConnectSession, SessionUpdated (connected/disconnected)
    func notify() {
        showCompletionPanel()
        update()
    }

}
