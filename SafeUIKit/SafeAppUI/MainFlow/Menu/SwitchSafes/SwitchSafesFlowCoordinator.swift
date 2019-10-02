//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import MultisigWalletApplication

class SwitchSafesFlowCoordinator: FlowCoordinator {

    let removeSafeFlowCoordinator = RemoveSafeFlowCoordinator()
    var initialSelection: String?

    override func setUp() {
        super.setUp()
        initialSelection = ApplicationServiceRegistry.walletService.selectedWalletID()
        let controller = SwitchSafesTableViewController()
        controller.delegate = self
        push(controller)
    }

    override func setRoot(_ controller: UIViewController) {
        guard rootViewController !== controller else {
            return
        }
        super.setRoot(controller)
        [removeSafeFlowCoordinator, MainFlowCoordinator.shared].forEach { $0?.setRoot(controller) }
    }

    func switchToRoot() {
        MainFlowCoordinator.shared.switchToRootController()
        // preventing memory leak due to retained view controllers
        self.setRoot(MainFlowCoordinator.shared.rootViewController)
    }

}

extension SwitchSafesFlowCoordinator: SwitchSafesTableViewControllerDelegate {

    func switchSafesTableViewController(_ controller: SwitchSafesTableViewController,
                                        didRequestToRemove wallet: WalletData) {
        removeSafeFlowCoordinator.walletID = wallet.id
        removeSafeFlowCoordinator.requiresRecoveryPhrase = wallet.requiresBackupToRemove
        saveCheckpoint()
        enter(flow: removeSafeFlowCoordinator) { [unowned self] in
            DispatchQueue.main.async {
                if ApplicationServiceRegistry.walletService.wallets().isEmpty {
                    self.switchToRoot()
                } else {
                    self.popToLastCheckpoint()
                }
            }
        }
    }

    func switchSafesTableViewControllerDidFinish(_ controller: SwitchSafesTableViewController) {
        let currentSelection = ApplicationServiceRegistry.walletService.selectedWalletID()
        guard currentSelection != initialSelection else { return }
        self.switchToRoot()
    }

}
