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
        saveCheckpoint()
    }

    func enterAndComeBack(from coordinator: FlowCoordinator) {
        saveCheckpoint()
        enter(flow: coordinator) {
            self.popToLastCheckpoint()
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
        push(PendingSafeViewController.create(delegate: self))
    }

}

extension NewSafeFlowCoordinator: PairWithBrowserDelegate {

    func didPair() {
        pop()
    }

}

extension NewSafeFlowCoordinator: PendingSafeViewControllerDelegate {

    func deploymentDidFail() {
        let controller = SafeCreationFailedAlertController.create { [unowned self] in
            self.dismissModal()
            self.popToLastCheckpoint()
        }
        presentModally(controller)
    }

    func deploymentDidSuccess() {
        exitFlow()
    }

    func deploymentDidCancel() {
        let controller = AbortSafeCreationAlertController.create(abort: { [unowned self] in
            self.dismissModal()
            self.popToLastCheckpoint()
        }, continue: { [unowned self] in
            self.dismissModal()
        })
        presentModally(controller)
    }

}
