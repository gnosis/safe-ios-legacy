//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import SafariServices
import MultisigWalletApplication
import MessageUI

class GetInTouchTableViewController: UITableViewController {

    enum Strings {
        static let title = LocalizedString("get_in_touch", comment: "Get In Touch").capitalized
        static let telegram = LocalizedString("telegram", comment: "Telegram")
        static let email = LocalizedString("email", comment: "E-mail")
        static let gitter = LocalizedString("gitter", comment: "Gitter")
    }

    struct Cell {
        var image: UIImage
        var text: String
        var action: () -> Void
    }

    var cells = [Cell]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title

        tableView.backgroundColor = ColorName.white.color
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "BasicTableViewCell",
                                 bundle: Bundle(for: BasicTableViewCell.self)),
                           forCellReuseIdentifier: "BasicTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = 0
        generateCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MenuTrackingEvent.getInTouch)
    }

    private func generateCells() {
        cells = [
            Cell(image: Asset.GetInTouch.telegram.image, text: Strings.telegram) { [unowned self] in
                self.openTelegram()
            },
            Cell(image: Asset.GetInTouch.mail.image, text: Strings.email) { [unowned self] in
                 self.openMail()
            },
            Cell(image: Asset.GetInTouch.gitter.image, text: Strings.gitter) { [unowned self] in
                self.openGitter()
            }
        ]
    }

    func openTelegram() {
        trackEvent(MenuTrackingEvent.telegram)
        openInSafari(ApplicationServiceRegistry.walletService.configuration.telegramURL)
    }

    private lazy var mailComposeHandler = MailComposeHandler()

    func openMail() {
        trackEvent(MenuTrackingEvent.email)
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = mailComposeHandler
            composeVC.setToRecipients([ApplicationServiceRegistry.walletService.configuration.supportMail])
            // 08.08.2019: Product decision was not to localise this mail.
            composeVC.setSubject("Feedback")
            let message = """
            \(SystemInfo.appVersionText)
            Safe addresses: \(ApplicationServiceRegistry.walletService.selectedWalletAddress ?? "None")
            Feedback:
            """
            composeVC.setMessageBody(message, isHTML: false)
            present(composeVC, animated: true, completion: nil)
        } else {
            present(UIAlertController.mailClientIsNotConfigured(), animated: true, completion: nil)
        }
    }

    func openGitter() {
        trackEvent(MenuTrackingEvent.gitter)
        openInSafari(ApplicationServiceRegistry.walletService.configuration.gitterURL)
    }

    func openInSafari(_ url: URL) {
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableViewCell",
                                                 for: indexPath) as! BasicTableViewCell
        cell.configure(with: cells[indexPath.row])
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        cells[indexPath.row].action()
    }

}

fileprivate extension BasicTableViewCell {

    func configure(with cell: GetInTouchTableViewController.Cell) {
        leftImageView.image = cell.image
        leftTextLabel.text = cell.text
    }

}

fileprivate class MailComposeHandler: NSObject, MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }

}
