//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class LoadMultisigFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        let controller = LoadMultisigIntroViewController.create(delegate: self)
        push(controller)
    }

    func switchToRoot() {
        MainFlowCoordinator.shared.switchToRootController()
        // preventing memory leak due to retained view controllers
        self.setRoot(MainFlowCoordinator.shared.rootViewController)
    }

}

extension LoadMultisigFlowCoordinator: LoadMultisigIntroViewControllerDelegate {

    func loadMultisigIntroViewControllerDidSelectLoad(_ controller: LoadMultisigIntroViewController) {
        let controller = LoadMultisigSelectTableViewController(style: .grouped)
        controller.delegate = self
        push(controller)
    }

}

extension LoadMultisigFlowCoordinator: LoadMultisigSelectTableViewControllerDelegate {

    func loadMultisigSelectTableViewController(controller: LoadMultisigSelectTableViewController,
                                               didSelectSafes safes: [WalletData]) {
        safes.forEach { walletData in
            if !ApplicationServiceRegistry.walletService.createAndSelectMultisigWallet(walletData: walletData) {
                print("error: Could not import wallet with data: \(walletData)")
            }
        }
        self.switchToRoot()
    }

}
