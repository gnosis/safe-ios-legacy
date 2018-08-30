//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class ManageTokensFlowCoordinator: FlowCoordinator {

    var manageTokensVC: ManageTokensTableViewController!
    var addTokenNavigationController: UINavigationController!

    override func setUp() {
        super.setUp()
        manageTokensVC = ManageTokensTableViewController()
        manageTokensVC.delegate = self
        push(manageTokensVC)
    }

}

// TODO: In Application Service: blacklist old
extension ManageTokensFlowCoordinator: ManageTokensTableViewControllerDelegate {

    func addToken() {
        addTokenNavigationController = AddTokenTableViewController.create(delegate: self)
        presentModally(addTokenNavigationController)
    }

    func rearrange(tokens: [TokenData]) {
        ApplicationServiceRegistry.walletService.rearrange(tokens: tokens)
    }

}

extension ManageTokensFlowCoordinator: AddTokenTableViewControllerDelegate {

    func didSelectToken(_ tokenData: TokenData) {
        ApplicationServiceRegistry.walletService.whitelist(token: tokenData)
        addTokenNavigationController.dismiss(animated: true)
        manageTokensVC.tokenAdded()
    }

}
