//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class NewSafeFlowCoordinator: FlowCoordinator {

    var paperWalletFlowCoordinator = PaperWalletFlowCoordinator()

    override func setUp() {
        super.setUp()
        push(NewSafeViewController.create(delegate: self))
    }

    func enterAndComeBack(from coordinator: FlowCoordinator) {
        let startVC = navigationController.topViewController
        enter(flow: coordinator) {
            if let startVC = startVC {
                self.pop(to: startVC)
            }
        }
    }

}

extension NewSafeFlowCoordinator: NewSafeDelegate {

    func didSelectPaperWalletSetup() {
        enterAndComeBack(from: paperWalletFlowCoordinator)
    }

    func didSelectBrowserExtensionSetup() {
        push(PairWithBrowserExtensionViewController.create(delegate: self))
    }

    func didSelectNext() {
        push(PendingSafeViewController())
    }

}

extension NewSafeFlowCoordinator: PairWithBrowserDelegate {

    func didPair() {
        pop()
    }

}
