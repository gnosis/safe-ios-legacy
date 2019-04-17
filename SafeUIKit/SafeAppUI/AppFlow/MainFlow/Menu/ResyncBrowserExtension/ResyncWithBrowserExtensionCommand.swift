//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class ResyncWithBrowserExtensionCommand: MenuCommand {

    override var title: String {
        return LocalizedString("sync_with_extension", comment: "Sync with browser extension").capitalized
    }

    override var isHidden: Bool {
        return !ApplicationServiceRegistry.disconnectExtensionService.isAvailable
    }

    override var hasDisclosure: Bool {
        return false
    }

    override func run(mainFlowCoordinator: MainFlowCoordinator) {
        DispatchQueue.global().async { [weak self] in
            do {
                try ApplicationServiceRegistry.settingsService.resyncWithBrowserExtension()
                DispatchQueue.main.async {
                    self?.showSuccess(mainFlowCoordinator: mainFlowCoordinator)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showError(error, mainFlowCoordinator: mainFlowCoordinator)
                }
            }
        }
    }

    func showSuccess(mainFlowCoordinator: MainFlowCoordinator) {
        let alert = UIAlertController(title: LocalizedString("alert.info.title", comment: "Info"),
                                      message: LocalizedString("resync.alert.success", comment: "Success"),
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedString("alert.error.ok", comment: "OK"),
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        mainFlowCoordinator.presentModally(alert)
    }

    func showError(_ error: Error, mainFlowCoordinator: MainFlowCoordinator) {
        let alert = UIAlertController(title: LocalizedString("alert.error.title", comment: "Error"),
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedString("alert.error.ok", comment: "OK"),
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        mainFlowCoordinator.presentModally(alert)

    }

}
