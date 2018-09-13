//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

protocol MenuTableViewControllerDelegate: class {
    func didSelectManageTokens()
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
        var image: UIImage
    }

    struct SafeQRCode {
        var address: String
    }

    struct MenuItem {
        var name: String
    }

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
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = ColorName.paleGreyThree.color
        tableView.separatorStyle = .singleLine
        tableView.sectionHeaderHeight = 38
        tableView.register(MenuItemTableViewCell.self, forCellReuseIdentifier: "MenuItemTableViewCell")
        tableView.register(SafeQRCodeTableViewCell.self, forCellReuseIdentifier: "SafeQRCodeTableViewCell")

        generateData()
    }

    private func generateData() {
        menuItems = [
            (section: .safe,
             items: [
                (item: SafeDescription(
                    address: "0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c", // TODO: provide real address
                    image: UIImage.createBlockiesImage(
                        seed: "0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c")),
                 cellHeight: { return SafeTableViewCell.height }),
                (item: SafeQRCode(address: "0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c"),
                 cellHeight: { return self.showQRCode ? 250 : 0 })
             ],
             title: Strings.safeAddressSectionTitle),
            (section: .portfolio,
             items: [menuItem(Strings.manageTokens)],
             title: Strings.portfolioSectionTitle),
            (section: .security,
             items: [
                menuItem(Strings.changePassword),
                menuItem(Strings.changeRecoveryPhrase),
                menuItem(Strings.changeBrowserExtension)],
             title: Strings.securitySectionTitle),
            (section: .support,
             items: [
                menuItem(Strings.feedback),
                menuItem(Strings.terms),
                menuItem(Strings.privacyPolicy),
                menuItem(Strings.rateApp)],
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
            let menuItem = menuItems[indexPath.section].items[indexPath.row].item as! MenuItem
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell", for: indexPath)
            cell.textLabel?.text = menuItem.name
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menuItems[section].title
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch menuItems[indexPath.section].section {
        case .portfolio:
            if let manageTokensItem = menuItems[indexPath.section].items[indexPath.row].item as? MenuItem,
                manageTokensItem.name == Strings.manageTokens {
                delegate?.didSelectManageTokens()
            }
            fallthrough
        default: tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return menuItems[indexPath.section].items[indexPath.row].cellHeight()
    }

}
