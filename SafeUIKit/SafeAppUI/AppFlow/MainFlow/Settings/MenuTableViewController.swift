//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

protocol MenuTableViewControllerDelegate: class {
    func didSelectManageTokens()
}

final class MenuTableViewController: UITableViewController {

    weak var delegate: MenuTableViewControllerDelegate?

    private var menuItems = [(section: SettingsSection, items: [(item: Any, cellHeight: CGFloat)])]()

    private enum Strings {
        static let manageTokens = LocalizedString("menu.action.manage_tokens", comment: "Manage Tokens menu item")
        static let changePassword = LocalizedString("menu.action.change_password",
                                                    comment: "Change password menu item")
        static let changeRecoveryPhrase = LocalizedString("menu.action.change_recovery_phrase",
                                                          comment: "Change recovery key  menu item")
        static let changeBrowserExtension = LocalizedString("menu.action.change_browser_extension",
                                                            comment: "Change browser extension menu item")
        static let terms = LocalizedString("menu.action.terms",
                                           comment: "Terms menu item")
        static let privacyPolicy = LocalizedString("menu.action.privacy_policy",
                                                   comment: "Privacy policy menu item")
        static let rateApp = LocalizedString("menu.action.rate_app",
                                             comment: "Rate App menu item")
    }

    struct SafeDescription {
        var address: String
        var name: String
        var image: UIImage
    }

    struct MenuItem {
        var name: String
        var icon: UIImage?
    }

    enum SettingsSection: Hashable {
        case safe
        case owners
        case legal
        case rateApp
    }

    static func create() -> MenuTableViewController {
        return StoryboardScene.Main.menuTableViewController.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = ColorName.paleGreyThree.color
        tableView.separatorStyle = .singleLine
        generateData()
    }

    private func generateData() {
        menuItems = [
            (.safe, [
                (item: SafeDescription(
                    address: "0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c",
                    name: "Gnosis Safe",
                    image: UIImage.createBlockiesImage(seed: "0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c")),
                 cellHeight: 90),
                (item: MenuItem(name: Strings.manageTokens, icon: nil),
                 cellHeight: 54)
            ]),
            (.owners, [
                (item: MenuItem(name: Strings.changePassword, icon: nil), cellHeight: 54),
                (item: MenuItem(name: Strings.changeRecoveryPhrase, icon: nil), cellHeight: 54),
                (item: MenuItem(name: Strings.changeBrowserExtension, icon: nil),
                 cellHeight: 54)
            ]),
            (.legal, [
                (item: MenuItem(name: Strings.terms, icon: nil), cellHeight: 54),
                (item: MenuItem(name: Strings.privacyPolicy, icon: nil), cellHeight: 54)
            ]),
            (.rateApp, [
                (item: MenuItem(name: Strings.rateApp, icon: nil), cellHeight: 54)
            ])
        ]
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedSafeTableViewCell", for: indexPath)
                    as! SelectedSafeTableViewCell
                cell.configure(safe: safeDescription)
                return cell
            } else {
                let menuItem = menuItems[indexPath.section].items[indexPath.row].item as! MenuItem
                let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell", for: indexPath)
                    as! MenuItemTableViewCell
                cell.configure(menuItem: menuItem)
                return cell
            }
        case .owners, .legal, .rateApp:
            let menuItem = menuItems[indexPath.section].items[indexPath.row].item as! MenuItem
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell", for: indexPath)
                as! MenuItemTableViewCell
            cell.configure(menuItem: menuItem)
            return cell
        }
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch menuItems[indexPath.section].section {
        case .safe:
            if let manageTokensItem = menuItems[indexPath.section].items[indexPath.row].item as? MenuItem,
                manageTokensItem.name == Strings.manageTokens {
                delegate?.didSelectManageTokens()
            }
            fallthrough
        default:tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return menuItems[indexPath.section].items[indexPath.row].cellHeight
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 25
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

}
