//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

final class NewSafeFlowCoordinator: FlowCoordinator {

    var paperWalletFlowCoordinator = PaperWalletFlowCoordinator()
    var pairController: PairWithBrowserExtensionViewController?

    var isSafeCreationInProgress: Bool {
        return ApplicationServiceRegistry.walletService.isSafeCreationInProgress
    }

    override func setUp() {
        super.setUp()
        if ApplicationServiceRegistry.walletService.hasReadyToUseWallet {
            exitFlow()
            return
        }
        push(NewSafeViewController.create(delegate: self))
        saveCheckpoint()
        if ApplicationServiceRegistry.walletService.isSafeCreationInProgress {
            push(SafeCreationViewController.create(delegate: self))
        }
    }

}

extension NewSafeFlowCoordinator {

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
        pairController = PairWithBrowserExtensionViewController.create { [unowned self] address, code in
            self.didPair(address: address, code: code)
        }
        push(pairController!)
    }

    func didSelectNext() {
        push(SafeCreationViewController.create(delegate: self))
    }

    private func didPair(address: String, code: String) {
        guard let pairController = pairController else { return }
        do {
            try ApplicationServiceRegistry.walletService.addBrowserExtensionOwner(
                address: address, browserExtensionCode: code)
            self.pop()
        } catch let e {
            pairController.handleError(e)
        }
    }

}

extension NewSafeFlowCoordinator: SafeCreationViewControllerDelegate {

    func deploymentDidFail(_ error: String) {
        let controller = SafeCreationFailedAlertController.create(localizedErrorDescription: error) { [unowned self] in
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
