//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import MultisigWalletApplication

class SwitchSafesFlowCoordinator: FlowCoordinator {

    let removeSafeFlowCoordinator = RemoveSafeFlowCoordinator()
    weak var mainFlowCoordinator: MainFlowCoordinator!
    var initialSelection: String?

    override func setUp() {
        super.setUp()
        assert(mainFlowCoordinator != nil)
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
        [removeSafeFlowCoordinator, mainFlowCoordinator].forEach { $0?.setRoot(controller) }
    }
}

extension SwitchSafesFlowCoordinator: SwitchSafesTableViewControllerDelegate {

    func switchSafesTableViewController(_ controller: SwitchSafesTableViewController, didSelect wallet: WalletData) {
        ApplicationServiceRegistry.walletService.selectWallet(wallet.id)
    }

    func switchSafesTableViewController(_ controller: SwitchSafesTableViewController,
                                        didRequestToRemove wallet: WalletData) {
        removeSafeFlowCoordinator.safeAddress = wallet.address
        saveCheckpoint()
        enter(flow: removeSafeFlowCoordinator) {
            DispatchQueue.main.async { [unowned self] in
                self.popToLastCheckpoint()
                if ApplicationServiceRegistry.walletService.wallets().isEmpty {
                    self.exitFlow()                    
                }
            }
        }
    }

    func switchSafesTableViewControllerDidFinish(_ controller: SwitchSafesTableViewController) {
        let currentSelection = ApplicationServiceRegistry.walletService.selectedWalletID()
        guard currentSelection != initialSelection else { return }
        mainFlowCoordinator.switchToRootController()
        setRoot(mainFlowCoordinator.rootViewController)
    }

}
