//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import MultisigWalletApplication

class SwitchSafesFlowCoordinator: FlowCoordinator {

    let removeSafeFlowCoordinator = RemoveSafeFlowCoordinator()

    override func setUp() {
        super.setUp()
        let controller = SwitchSafesTableViewController()
        controller.delegate = self
        push(controller)
    }
}

extension SwitchSafesFlowCoordinator: SwitchSafesTableViewControllerDelegate {

    func didSelect(wallet: WalletData) {}

    func didRequestToRemove(wallet: WalletData) {
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

}
