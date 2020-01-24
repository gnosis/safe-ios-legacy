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
            ApplicationServiceRegistry.walletService.createAndSelectMultisigWallet(walletData: walletData)
        }
        exitFlow()
    }

}
