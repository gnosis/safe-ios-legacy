//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class SettingsTableViewController: UITableViewController {

    private var settings = [(section: SettingsSection, items: [(item: Any, cellHeight: CGFloat)])]()

    private enum Strings {
        static let manageTokens = LocalizedString("settings.action.manage_tokens", comment: "Manage Tokens menu item")
        static let changePassword = LocalizedString("settings.action.change_password",
                                                    comment: "Change password menu item")
        static let changeRecoveryPhrase = LocalizedString("settings.action.change_recovery_phrase",
                                                          comment: "Change recovery key  menu item")
        static let changeBrowserExtension = LocalizedString("settings.action.change_broeser_extension",
                                                            comment: "Change browser extension menu item")
        static let terms = LocalizedString("settings.action.terms",
                                           comment: "Terms menu item")
        static let privacyPolicy = LocalizedString("settings.action.privacy_policy",
                                                   comment: "Privacy policy menu item")
        static let rateApp = LocalizedString("settings.action.rate_app",
                                             comment: "Rate App menu item")
    }

    struct SafeDescription {
        var address: String
        var name: String
        var image: UIImage
    }

    struct MenuItem {
        var name: String
        var icon: UIImage
    }

    enum SettingsSection: Hashable {
        case safe
        case owners
        case legal
        case rateApp
    }

    public static func create() -> SettingsTableViewController {
        return StoryboardScene.Main.settingsTableViewController.instantiate()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = ColorName.paleGreyThree.color
        tableView.separatorStyle = .singleLine
        generateData()
    }

    private func generateData() {
        settings = [
            (.safe, [
                (item: SafeDescription(
                    address: "0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c",
                    name: "Gnosis Safe",
                    image: UIImage.createBlockiesImage(seed: "0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c")),
                 cellHeight: 90),
                (item: MenuItem(name: Strings.manageTokens, icon: Asset.TokenIcons.eth.image),
                 cellHeight: 54)
            ]),
            (.owners, [
                (item: MenuItem(name: Strings.changePassword, icon: Asset.TokenIcons.eth.image), cellHeight: 54),
                (item: MenuItem(name: Strings.changeRecoveryPhrase, icon: Asset.TokenIcons.btc.image), cellHeight: 54),
                (item: MenuItem(name: Strings.changeBrowserExtension, icon: Asset.TokenIcons.gnt.image),
                 cellHeight: 54)
            ]),
            (.legal, [
                (item: MenuItem(name: Strings.terms, icon: Asset.TokenIcons.eth.image), cellHeight: 54),
                (item: MenuItem(name: Strings.privacyPolicy, icon: Asset.TokenIcons.btc.image), cellHeight: 54)
            ]),
            (.rateApp, [
                (item: MenuItem(name: Strings.rateApp, icon: Asset.TokenIcons.eth.image), cellHeight: 54)
            ])
        ]
    }

    // MARK: - Table view data source

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].items.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch settings[indexPath.section].section {
        case .safe:
            if let safeDescription = settings[indexPath.section].items[indexPath.row].item as? SafeDescription {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedSafeTableViewCell", for: indexPath)
                    as! SelectedSafeTableViewCell
                cell.configure(safe: safeDescription)
                return cell
            } else {
                let menuItem = settings[indexPath.section].items[indexPath.row].item as! MenuItem
                let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell", for: indexPath)
                    as! MenuItemTableViewCell
                cell.configure(menuItem: menuItem)
                return cell
            }
        case .owners, .legal, .rateApp:
            let menuItem = settings[indexPath.section].items[indexPath.row].item as! MenuItem
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell", for: indexPath)
                as! MenuItemTableViewCell
            cell.configure(menuItem: menuItem)
            return cell
        }
    }

    // MARK: - Table view delegate

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return settings[indexPath.section].items[indexPath.row].cellHeight
    }

    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }

    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

}
