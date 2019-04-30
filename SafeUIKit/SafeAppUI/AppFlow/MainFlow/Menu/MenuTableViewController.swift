//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol MenuTableViewControllerDelegate: class {
    func didSelectCommand(_ command: MenuCommand)
}

final class MenuItemTableViewCell: UITableViewCell {
    static let height: CGFloat = 44
}

final class MenuTableViewController: UITableViewController {

    weak var delegate: MenuTableViewControllerDelegate?

    private var selectedSafeAddress: String? {
        return ApplicationServiceRegistry.walletService.selectedWalletAddress
    }

    enum SettingsSection: Hashable {
        case safe
        case portfolio
        case security
        case support
    }

    struct MenuItem {
        var name: String
        var hasDisclosure: Bool
        var height: CGFloat
    }

    static func create() -> MenuTableViewController {
        return StoryboardScene.Main.menuTableViewController.instantiate()
    }

    private var menuItemSections = [(section: SettingsSection, title: String, items: [MenuItem])]()

    private enum Strings {
        static let title = LocalizedString("menu", comment: "Title for menu screen.")
        static let address = LocalizedString("address", comment: "Title for safe address section.").uppercased()
        static let portfolio = LocalizedString("portfolio", comment: "Title for portfolio section.").uppercased()
        static let security = LocalizedString("security", comment: "Title for security section.").uppercased()
        static let support = LocalizedString("support", comment: "Title for support section.").uppercased()

        // not used yet
        static let feedback = LocalizedString("give_feedback", comment: "Feedback and FAQ menu item").capitalized
        static let rateApp = LocalizedString("rate_app", comment: "Rate App menu item").capitalized
    }

    // MARK: - Commands

    let selectSafeCommand = SelectSafeCommand()
    var switchSafeCommands: [MenuCommand] {
        return [selectSafeCommand]
    }

    let manageTokensCommand = ManageTokensCommand()
    var portfolioCommands: [MenuCommand] {
        return [manageTokensCommand]
    }

    let changePasswordCommand = ChangePasswordCommand()
    let resyncCommand = ResyncWithBrowserExtensionCommand()
    let replaceRecoveryPhraseCommand = ReplaceRecoveryPhraseCommand()
    let replaceCommand = ReplaceBrowserExtensionCommand()
    let connectCommand = ConnectBrowserExtensionLaterCommand()
    let disconnectCommand = DisconnectBrowserExtensionCommand()
    var securityCommands: [MenuCommand] {
        return [changePasswordCommand, resyncCommand, replaceRecoveryPhraseCommand, replaceCommand, connectCommand,
                disconnectCommand]
    }

    let termsCommand = TermsCommand()
    let privacyPolicyCommand = PrivacyPolicyCommand()
    let licensesCommand = LicensesCommand()
    var supportCommands: [MenuCommand] {
        return [termsCommand, privacyPolicyCommand, licensesCommand]
    }

    // MARK: - VC Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title

        tableView.backgroundColor = ColorName.paleGreyThree.color
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.register(MenuItemTableViewCell.self, forCellReuseIdentifier: "MenuItemTableViewCell")
        tableView.register(BackgroundHeaderFooterView.self,
                           forHeaderFooterViewReuseIdentifier: "BackgroundHeaderFooterView")
        tableView.sectionFooterHeight = 0
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
        menuItemSections = selectedSafeAddress == nil ? [] : [
            (section: .safe,
             title: Strings.address,
             items: [MenuItem(name: "SAFE", hasDisclosure: false, height: SafeTableViewCell.height)])
        ]
        menuItemSections += [
            (section: .portfolio,
             title: Strings.portfolio,
             items: sectionItems(for: portfolioCommands)),

            (section: .security,
             title: Strings.security,
             items: sectionItems(for: securityCommands)),

            (section: .support,
             title: Strings.support,
             items: sectionItems(for: supportCommands) +
                [MenuItem(name: "AppVersion", hasDisclosure: false, height: AppVersionTableViewCell.height)])
        ]
    }

    private func sectionItems(for commands: [MenuCommand]) -> [MenuItem] {
        return commands.filter { !$0.isHidden }.map {
            MenuItem(name: $0.title, hasDisclosure: $0.hasDisclosure, height: $0.height)
        }
    }

    func index(of section: SettingsSection) -> Int? {
        return menuItemSections.enumerated().first { offset, item in item.section == section }?.offset
    }

    private func menuItem(at indexPath: IndexPath) -> MenuItem {
        return menuItemSections[indexPath.section].items[indexPath.row]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return menuItemSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemSections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch menuItemSections[indexPath.section].section {
        case .safe:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SafeTableViewCell",
                                                     for: indexPath) as! SafeTableViewCell
            cell.configure(address: selectedSafeAddress!)
            return cell
        case .safe, .portfolio, .security, .support:
            let item = menuItem(at: indexPath)
            if item.name == "AppVersion" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AppVersionTableViewCell", for: indexPath)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell", for: indexPath)
            cell.textLabel?.text = item.name
            cell.accessoryType = item.hasDisclosure ? .disclosureIndicator : .none
            return cell
        }
    }

    // MARK: - Table view delegate

    //swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = menuItem(at: indexPath)

        switch menuItemSections[indexPath.section].section {
        case .portfolio:
            switch item.name {
            case manageTokensCommand.title:
                delegate?.didSelectCommand(manageTokensCommand)
            default: break
            }

        case .security:
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
            case replaceRecoveryPhraseCommand.title:
                delegate?.didSelectCommand(replaceRecoveryPhraseCommand)
            default: break
            }

        case .support:
            switch item.name {
            case termsCommand.title:
                delegate?.didSelectCommand(termsCommand)
            case privacyPolicyCommand.title:
                delegate?.didSelectCommand(privacyPolicyCommand)
            case licensesCommand.title:
                delegate?.didSelectCommand(licensesCommand)
            default: break
            }

        default: break
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return menuItem(at: indexPath).height
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BackgroundHeaderFooterView")
            as! BackgroundHeaderFooterView
        view.title = menuItemSections[section].title.uppercased()
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return BackgroundHeaderFooterView.height
    }

}
