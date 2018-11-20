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
    func didSelectConnectBrowserExtension()
    func didSelectChangeBrowserExtension()
}

final class MenuItemTableViewCell: UITableViewCell {
    static let height: CGFloat = 44
}

final class MenuTableViewController: UITableViewController {

    weak var delegate: MenuTableViewControllerDelegate?

    private var menuItems =
        [(section: SettingsSection, items: [(item: Any, cellHeight: () -> CGFloat)], title: String)]()

    private enum Strings {
        static let title = LocalizedString("menu.title", comment: "Title for menu screen.")
        static let safeAddressSectionTitle = LocalizedString("menu.section.safe.title",
                                                             comment: "Title for safe address section.")
        static let portfolioSectionTitle = LocalizedString("menu.section.portfolio.title",
                                                           comment: "Title for portfolio section.")
        static let securitySectionTitle = LocalizedString("menu.section.security.title",
                                                          comment: "Title for security section.")
        static let supportSectionTitle = LocalizedString("menu.section.support.title",
                                                         comment: "Title for support section.")
        static let manageTokens = LocalizedString("menu.action.manage_tokens", comment: "Manage Tokens menu item")
        static let changePassword = LocalizedString("menu.action.change_password",
                                                    comment: "Change password menu item")
        static let changeRecoveryPhrase = LocalizedString("menu.action.change_recovery_phrase",
                                                          comment: "Change recovery key  menu item")
        static let changeBrowserExtension = LocalizedString("menu.action.change_browser_extension",
                                                            comment: "Change browser extension menu item")
        static let connectBrowserExtension = LocalizedString("menu.action.connect_browser_extension",
                                                             comment: "Connect browser extension menu item")
        static let feedback = LocalizedString("menu.action.feedback_and_faq", comment: "Feedback and FAQ menu item")
        static let terms = LocalizedString("menu.action.terms",
                                           comment: "Terms menu item")
        static let privacyPolicy = LocalizedString("menu.action.privacy_policy",
                                                   comment: "Privacy policy menu item")
        static let rateApp = LocalizedString("menu.action.rate_app",
                                             comment: "Rate App menu item")
    }

    struct SafeDescription {
        var address: String
    }

    struct SafeQRCode {
        var address: String
    }

    struct MenuItem {
        var name: String
    }

    struct AppVersion {}

    enum SettingsSection: Hashable {
        case safe
        case portfolio
        case security
        case support
    }

    private var showQRCode = false

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
        tableView.backgroundColor = ColorName.paleGreyThree.color
        tableView.separatorStyle = .singleLine
        tableView.register(MenuItemTableViewCell.self, forCellReuseIdentifier: "MenuItemTableViewCell")
        tableView.register(BackgroundHeaderFooterView.self,
                           forHeaderFooterViewReuseIdentifier: "BackgroundHeaderFooterView")
        tableView.sectionFooterHeight = 0

        generateData()
    }

    private func generateData() {
        guard let address = ApplicationServiceRegistry.walletService.selectedWalletAddress else { return }
        let hasBrowserExtension = ApplicationServiceRegistry.walletService.isOwnerExists(.browserExtension)
        let browserExtensionItem =
            hasBrowserExtension ? menuItem(Strings.changeBrowserExtension) : menuItem(Strings.connectBrowserExtension)
        menuItems = [
            (section: .safe,
             items: [
                (item: SafeDescription(address: address),
                 cellHeight: { return SafeTableViewCell.height }),
                (item: SafeQRCode(address: address),
                 cellHeight: { return self.showQRCode ? SafeQRCodeTableViewCell.height : 0 })
             ],
             title: Strings.safeAddressSectionTitle),
            (section: .portfolio,
             items: [menuItem(Strings.manageTokens)],
             title: Strings.portfolioSectionTitle),
            (section: .security,
             items: [
//                menuItem(Strings.changePassword),
//                menuItem(Strings.changeRecoveryPhrase),
                browserExtensionItem],
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

    private func menuItem(_ name: String, _ height: CGFloat = MenuItemTableViewCell.height) ->
        (item: Any, cellHeight: () -> CGFloat) {
            return (item: MenuItem(name: name), cellHeight: { return height })
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
            cell.accessoryType = .disclosureIndicator
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
            case Strings.connectBrowserExtension:
                delegate?.didSelectConnectBrowserExtension()
            case Strings.changeBrowserExtension:
                delegate?.didSelectChangeBrowserExtension()
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
        let view = BackgroundHeaderFooterView()
        view.label.text = menuItems[section].title.uppercased()
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return BackgroundHeaderFooterView.height
    }

}
