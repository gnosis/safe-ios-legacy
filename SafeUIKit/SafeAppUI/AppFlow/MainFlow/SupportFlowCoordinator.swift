//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafariServices
import MultisigWalletApplication
import Common

final class SupportFlowCoordinator: FlowCoordinator {

    private let rootCoordinator: FlowCoordinator

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

}
