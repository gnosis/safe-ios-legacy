//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import Common

final class ManageTokensFlowCoordinator: FlowCoordinator {

    var manageTokensVC: ManageTokensTableViewController!
    var addTokenNavigationController: UINavigationController!

    override func setUp() {
        super.setUp()
        manageTokensVC = ManageTokensTableViewController()
        manageTokensVC.delegate = self
        let navController = UINavigationController(rootViewController: manageTokensVC)
        presentModally(navController)
    }

}

extension ManageTokensFlowCoordinator: ManageTokensTableViewControllerDelegate {

    func addToken() {
        addTokenNavigationController = AddTokenTableViewController.create(delegate: self)
        presentModally(addTokenNavigationController)
    }

    func rearrange(tokens: [TokenData]) {
        ApplicationServiceRegistry.walletService.rearrange(tokens: tokens)
    }

    func hide(token: TokenData) {
        ApplicationServiceRegistry.walletService.blacklist(token: token)
    }

}

extension ManageTokensFlowCoordinator: AddTokenTableViewControllerDelegate {

    func didSelectToken(_ tokenData: TokenData) {
        ApplicationServiceRegistry.walletService.whitelist(token: tokenData)
        addTokenNavigationController.dismiss(animated: true)
        manageTokensVC.tokenAdded()
    }

}
