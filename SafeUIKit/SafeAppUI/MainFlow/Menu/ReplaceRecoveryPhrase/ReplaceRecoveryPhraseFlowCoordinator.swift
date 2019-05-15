//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class ReplaceRecoveryPhraseFlowCoordinator: FlowCoordinator {

    weak var intro: ReplaceRecoveryPhraseViewController!

    override func setUp() {
        super.setUp()
        let vc = mnemonicIntroViewController()
        push(vc)
        intro = vc
    }

}

extension ReplaceRecoveryPhraseFlowCoordinator {

    func mnemonicIntroViewController() -> ReplaceRecoveryPhraseViewController {
        return ReplaceRecoveryPhraseViewController.create(delegate: self)
    }

    func saveMnemonicViewController() -> SaveMnemonicViewController {
        let controller = SaveMnemonicViewController.create(delegate: self, isRecoveryMode: true)
        controller.screenTrackingEvent = ReplaceRecoveryPhraseTrackingEvent.showSeed
        return controller
    }

    func confirmMnemonicViewController(_ vc: SaveMnemonicViewController) -> ConfirmMnemonicViewController {
        let controller = ConfirmMnemonicViewController.create(delegate: self,
                                                              account: vc.account,
                                                              isRecoveryMode: true)
        controller.screenTrackingEvent = ReplaceRecoveryPhraseTrackingEvent.enterSeed
        return controller
    }

}

extension ReplaceRecoveryPhraseFlowCoordinator: ReplaceRecoveryPhraseViewControllerDelegate {

    func replaceRecoveryPhraseViewControllerDidStart() {
        let controller = saveMnemonicViewController()
        push(controller) {
            controller.willBeDismissed()
        }
    }

}

extension ReplaceRecoveryPhraseFlowCoordinator: SaveMnemonicDelegate {

    func saveMnemonicViewControllerDidPressContinue(_ vc: SaveMnemonicViewController) {
        push(confirmMnemonicViewController(vc))
    }

}

extension ReplaceRecoveryPhraseFlowCoordinator: ConfirmMnemonicDelegate {

    func confirmMnemonicViewControllerDidConfirm(_ vc: ConfirmMnemonicViewController) {
        let txID = intro.transaction!.id
        let address = vc.account.address
        ApplicationServiceRegistry.settingsService.updateRecoveryPhraseTransaction(txID, with: address)
        let reviewVC = ReplaceRecoveryPhraseReviewTransactionViewController(transactionID: txID, delegate: self)
        push(reviewVC) { [unowned self] in // on pop
            self.exitFlow()
            DispatchQueue.global().async {
                ApplicationServiceRegistry.settingsService.cancelPhraseRecovery()
                ApplicationServiceRegistry.ethereumService.removeExternallyOwnedAccount(address: address)
            }
        }
    }

}

extension ReplaceRecoveryPhraseFlowCoordinator: ReviewTransactionViewControllerDelegate {

    public func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                        completion: @escaping (Bool) -> Void) {
        TransactionSubmissionHandler().submitTransaction(from: self, completion: completion)
    }

    public func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        exitFlow()
    }

}
