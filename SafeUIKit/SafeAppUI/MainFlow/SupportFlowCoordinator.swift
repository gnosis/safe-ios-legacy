//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafariServices
import MultisigWalletApplication
import Common
import MessageUI

final class SupportFlowCoordinator: FlowCoordinator {

    private let rootCoordinator: FlowCoordinator
    private lazy var mailComposeHandler = MailComposeHandler()

    init(from flowCoordinator: FlowCoordinator) {
        rootCoordinator = flowCoordinator
    }

    func openInSafari(_ url: URL?) {
        guard let url = url else {
            showURLNotAvailable()
            return
        }
        let safari = SFSafariViewController(url: url)
        rootCoordinator.presentModally(safari)
    }

    private func showURLNotAvailable() {
        let message = LocalizedString("ios_error_link_unavailable", comment: "URL not available message")
        let title = LocalizedString("error", comment: "Error title")
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okTitle = LocalizedString("ok", comment: "OK button title")
        let okAction = UIAlertAction(title: okTitle, style: .default)
        controller.addAction(okAction)
        rootCoordinator.presentModally(controller)
    }

    func openTermsOfUse() {
        Tracker.shared.track(event: MenuTrackingEvent.terms)
        openInSafari(ApplicationServiceRegistry.walletService.configuration.termsOfUseURL)
    }

    func openPrivacyPolicy() {
        Tracker.shared.track(event: MenuTrackingEvent.privacyPolicy)
        openInSafari(ApplicationServiceRegistry.walletService.configuration.privacyPolicyURL)
    }

    func openTransactionBrowser(_ transactionID: String) {
        openInSafari(ApplicationServiceRegistry.walletService.transactionURL(transactionID))
    }

    func openLicenses() {
        Tracker.shared.track(event: MenuTrackingEvent.licenses)
        openInSafari(ApplicationServiceRegistry.walletService.configuration.licensesURL)
    }

    func openRateApp() {
        Tracker.shared.track(event: MenuTrackingEvent.rateApp)
        openInSafari(ApplicationServiceRegistry.walletService.configuration.appStoreReviewUrl)
    }

    func openTelegram() {
        Tracker.shared.track(event: MenuTrackingEvent.telegram)
        openInSafari(ApplicationServiceRegistry.walletService.configuration.telegramURL)
    }

    func openGitter() {
        Tracker.shared.track(event: MenuTrackingEvent.gitter)
        openInSafari(ApplicationServiceRegistry.walletService.configuration.gitterURL)
    }

    func openMail() {
        Tracker.shared.track(event: MenuTrackingEvent.email)
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
            rootCoordinator.presentModally(composeVC)
        } else {
            rootCoordinator.presentModally(UIAlertController.mailClientIsNotConfigured())
        }
    }

    func openBlogPostForContractUpgrade_1_0_0() {
        Tracker.shared.track(event: ContractUpgradeTrackingEvent._1_0_0_openBlogArticle)
        // swiftlint:disable:next line_length
        openInSafari(URL(string: "https://blog.gnosis.pm/formal-verification-a-journey-deep-into-the-gnosis-safe-smart-contracts-b00daf354a9c")!)
    }

}

fileprivate class MailComposeHandler: NSObject, MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }

}
