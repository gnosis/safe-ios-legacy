//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol MenuTableViewControllerDelegate: class {
    func didSelectManageTokens()
    func didSelectTermsOfUse()
    func didSelectPrivacyPolicy()
    func didSelectReplaceRecoveryPhrase()
    func didSelectCommand(_ command: MenuCommand)
}

final class MenuItemTableViewCell: UITableViewCell {
    static let height: CGFloat = 44
}

final class MenuTableViewController: UITableViewController {

    weak var delegate: MenuTableViewControllerDelegate?

    private var menuItems =
        [(section: SettingsSection, items: [(item: Any, cellHeight: () -> CGFloat)], title: String)]()

    private enum Strings {
        static let title = LocalizedString("menu", comment: "Title for menu screen.")
        static let safeAddressSectionTitle =
            LocalizedString("address", comment: "Title for safe address section.").uppercased()
        static let portfolioSectionTitle =
            LocalizedString("portfolio", comment: "Title for portfolio section.").uppercased()
        static let securitySectionTitle =
            LocalizedString("security", comment: "Title for security section.").uppercased()
        static let supportSectionTitle = LocalizedString("support", comment: "Title for support section.").uppercased()
        static let manageTokens = LocalizedString("manage_tokens", comment: "Manage Tokens menu item").capitalized
        static let changePassword = LocalizedString("change_password", comment: "Change password menu item").capitalized
        static let changeRecoveryPhrase =
            LocalizedString("replace_recovery_phrase", comment: "Change recovery key menu item").capitalized
                .replacingOccurrences(of: "\n", with: " ").capitalized
        static let feedback = LocalizedString("give_feedback", comment: "Feedback and FAQ menu item").capitalized
        static let terms = LocalizedString("terms_of_service", comment: "Terms menu item").capitalized
        static let privacyPolicy = LocalizedString("privacy_policy", comment: "Privacy policy menu item").capitalized
        static let rateApp = LocalizedString("rate_app", comment: "Rate App menu item").capitalized
    }

    struct SafeDescription {
        var address: String
    }

    struct SafeQRCode {
        var address: String
    }

    struct MenuItem {
        var name: String
        var hasDisclosure: Bool
    }

    struct AppVersion {}

    enum SettingsSection: Hashable {
        case safe
        case portfolio
        case security
        case support
    }

    private var showQRCode = false
    let changePasswordCommand = ChangePasswordCommand()
    let replaceCommand = ReplaceBrowserExtensionCommand()
    let connectCommand = ConnectBrowserExtensionLaterCommand()
    let disconnectCommand = DisconnectBrowserExtensionCommand()
    let resyncCommand = ResyncWithBrowserExtensionCommand()

    var securityCommands: [MenuCommand] {
        return [changePasswordCommand, resyncCommand, replaceCommand, connectCommand, disconnectCommand]
    }

    static func create() -> MenuTableViewController {
        return StoryboardScene.Main.menuTableViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title

        let backgroundView = BackgroundImageView(frame: tableView.frame)
        backgroundView.isDimmed = true
        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.register(MenuItemTableViewCell.self, forCellReuseIdentifier: "MenuItemTableViewCell")
        tableView.register(BackgroundHeaderFooterView.self,
                           forHeaderFooterViewReuseIdentifier: "BackgroundHeaderFooterView")
        tableView.sectionFooterHeight = 0

        generateData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        generateData()
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MenuTrackingEvent.menu)
    }

    private func generateData() {
        guard let address = ApplicationServiceRegistry.walletService.selectedWalletAddress else { return }
        menuItems = [
            (section: .safe,
             items: [
                (item: SafeDescription(address: address),
                 cellHeight: { return SafeTableViewCell.height }),
                (item: SafeQRCode(address: address),
                 cellHeight: { return self.showQRCode ? UITableView.automaticDimension : 0 })
             ],
             title: Strings.safeAddressSectionTitle),
            (section: .portfolio,
             items: [menuItem(Strings.manageTokens)],
             title: Strings.portfolioSectionTitle),
            (section: .security,
             items:
                [
                menuItem(Strings.changeRecoveryPhrase)
                ] +
                    securityCommands.filter { !$0.isHidden }.map {
                        menuItem($0.title, hasDisclosure: $0.hasDisclosure)
                },
             title: Strings.securitySectionTitle),
            (section: .support,
             items: [
//                menuItem(Strings.feedback),
                menuItem(Strings.terms),
                menuItem(Strings.privacyPolicy),
//                menuItem(Strings.rateApp),
                (item: AppVersion(), cellHeight: { return AppVersionTableViewCell.height })],
             title: Strings.supportSectionTitle)
        ]
    }

    func index(of section: SettingsSection) -> Int? {
        return menuItems.enumerated().first { offset, item in item.section == section }?.offset
    }

    private func menuItem(_ name: String,
                          _ height: CGFloat = MenuItemTableViewCell.height,
                          hasDisclosure: Bool = true) -> (item: Any, cellHeight: () -> CGFloat) {
        return (item: MenuItem(name: name, hasDisclosure: hasDisclosure), cellHeight: { return height })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch menuItems[indexPath.section].section {
        case .safe:
            if let safeDescription = menuItems[indexPath.section].items[indexPath.row].item as? SafeDescription {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SafeTableViewCell", for: indexPath)
                    as! SafeTableViewCell
                cell.configure(safe: safeDescription, qrCodeShown: showQRCode)
                cell.onShare = { [unowned self] in
                    let activityController = UIActivityViewController(
                        activityItems: [safeDescription.address], applicationActivities: nil)
                    self.present(activityController, animated: true)
                }
                cell.onShowQRCode = { [unowned self] in
                    self.showQRCode = !self.showQRCode
                    self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                }
                return cell
            } else {
                let qrCodeItem = menuItems[indexPath.section].items[indexPath.row].item as! SafeQRCode
                let cell = tableView.dequeueReusableCell(withIdentifier: "SafeQRCodeTableViewCell", for: indexPath)
                    as! SafeQRCodeTableViewCell
                cell.configure(code: qrCodeItem)
                return cell
            }

        case .portfolio, .security, .support:
            if menuItems[indexPath.section].items[indexPath.row].item is AppVersion {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AppVersionTableViewCell", for: indexPath)
                return cell
            }
            let menuItem = menuItems[indexPath.section].items[indexPath.row].item as! MenuItem
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell", for: indexPath)
            cell.textLabel?.text = menuItem.name
            cell.accessoryType = menuItem.hasDisclosure ? .disclosureIndicator : .none
            return cell
        }
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch menuItems[indexPath.section].section {
        case .portfolio:
            if let manageTokensItem = menuItem(at: indexPath), manageTokensItem.name == Strings.manageTokens {
                delegate?.didSelectManageTokens()
            }
        case .security:
            let item = menuItem(at: indexPath)!
            switch item.name {
            case changePasswordCommand.title:
                delegate?.didSelectCommand(changePasswordCommand)
            case connectCommand.title:
                delegate?.didSelectCommand(connectCommand)
            case replaceCommand.title:
                delegate?.didSelectCommand(replaceCommand)
            case disconnectCommand.title:
                delegate?.didSelectCommand(disconnectCommand)
            case resyncCommand.title:
                delegate?.didSelectCommand(resyncCommand)
            case Strings.changeRecoveryPhrase:
                delegate?.didSelectReplaceRecoveryPhrase()
            default: break
            }
        case .support:
            if indexPath.row == 0 {
                delegate?.didSelectTermsOfUse()
            } else {
                delegate?.didSelectPrivacyPolicy()
            }
        default: break
        }
    }

    private func menuItem(at indexPath: IndexPath) -> MenuItem? {
        return menuItems[indexPath.section].items[indexPath.row].item as? MenuItem
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return menuItems[indexPath.section].items[indexPath.row].cellHeight()
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BackgroundHeaderFooterView")
            as! BackgroundHeaderFooterView
        view.label.text = menuItems[section].title.uppercased()
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return BackgroundHeaderFooterView.height
    }

}
