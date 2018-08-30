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

extension ManageTokensFlowCoordinator: ManageTokensTableViewControllerDelegate {

    func addToken() {
        addTokenNavigationController = AddTokenTableViewController.create(delegate: self)
        presentModally(addTokenNavigationController)
    }

    func endEditing(tokens: [TokenData]) {
        // TODO: In Application Service: whitelist new, blacklist old, new sorting ids, update balances
        print(tokens.map { $0.code }.joined(separator: ", "))
    }

}

extension ManageTokensFlowCoordinator: AddTokenTableViewControllerDelegate {

    func didSelectToken(_ tokenData: TokenData) {
        addTokenNavigationController.dismiss(animated: true)
        manageTokensVC.tokenAdded(tokenData: tokenData)
    }

}
