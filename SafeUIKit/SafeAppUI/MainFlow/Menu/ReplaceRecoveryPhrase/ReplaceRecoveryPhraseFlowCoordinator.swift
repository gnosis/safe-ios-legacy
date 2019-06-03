//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

// Intro -> New Mnemonic -> Verify that mnemonic is copied -> Review (with BE confirmation request) -> Success
class ReplaceRecoveryPhraseFlowCoordinator: FlowCoordinator {

    var transactionID: RBETransactionID!
    weak var introVC: RBEIntroViewController!

    override func setUp() {
        super.setUp()
        let vc = introController()
        push(vc)
        introVC = vc
    }

}

extension IntroContentView.Content {

    static let replacePhrase =
        IntroContentView.Content(header: LocalizedString("new_seed", comment: "Replace recovery phrase"),
                                 body: LocalizedString("this_will_generate_new_seed",
                                                       comment: "Text between stars (*) will be emphasized"),
                                 icon: Asset.replacePhrase.image)

}

extension ReplaceRecoveryPhraseFlowCoordinator {

    enum ReplaceRecoveryPhraseStrings {
        static let title = LocalizedString("ios_replace_recovery_phrase",
                                           comment: "Title for the header in review screen")
            .replacingOccurrences(of: "\n", with: " ")
        static let detail = LocalizedString("ios_replace_seed_details",
                                            comment: "Detail for the header in review screen")
    }

    func introController() -> RBEIntroViewController {
        let controller = RBEIntroViewController.create()
        controller.starter = ApplicationServiceRegistry.replacePhraseService
        controller.delegate = self
        controller.screenTrackingEvent = ReplaceRecoveryPhraseTrackingEvent.intro
        controller.setContent(.replacePhrase)
        return controller
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

    func reviewViewController() -> UIViewController {
        let vc = RBEReviewTransactionViewController(transactionID: transactionID, delegate: self)
        vc.titleString = ReplaceRecoveryPhraseStrings.title
        vc.detailString = ReplaceRecoveryPhraseStrings.detail
        vc.screenTrackingEvent = ReplaceRecoveryPhraseTrackingEvent.review
        vc.successTrackingEvent = ReplaceRecoveryPhraseTrackingEvent.success
        return vc
    }

}

extension ReplaceRecoveryPhraseFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        transactionID = introVC.transactionID
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
        let address = vc.account.address
        ApplicationServiceRegistry.replacePhraseService.update(transaction: transactionID, newAddress: address)
        push(reviewViewController())
    }

}

extension ReplaceRecoveryPhraseFlowCoordinator: ReviewTransactionViewControllerDelegate {

    public func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                        completion: @escaping (Bool) -> Void) {
        TransactionSubmissionHandler().submitTransaction(from: self, completion: completion)
    }

    public func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        ApplicationServiceRegistry.replacePhraseService.startMonitoring(transaction: transactionID)
        exitFlow()
    }

}
