//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class RemoveSafeFlowCoordinator: FlowCoordinator {

    var walletID: String!
    var requiresRecoveryPhrase: Bool = true
    lazy var replacePhraseCoordinator = ReplaceRecoveryPhraseFlowCoordinator()

    override func setUp() {
        super.setUp()
        push(removeSafeIntro())
    }

    private func removeSafeIntro() -> UIViewController {
        return RemoveSafeIntroViewController.create(walletID: walletID) { [unowned self] in
            if self.requiresRecoveryPhrase {
                self.push(self.removeSafeEnterSeed())
            } else {
                self.removeWallet()
            }
        }
    }

    private func removeWallet() {
        ApplicationServiceRegistry.walletService.removeWallet(id: walletID)
        exitFlow()
    }

    private func removeSafeEnterSeed() -> UIViewController {
        let controller = RecoveryPhraseInputViewController.create(delegate: self)
        controller.title = RemoveSafeIntroViewController.Strings.title
        controller.screenTrackingEvent = SafesTrackingEvent.removeSafeEnterSeed
        controller.nextButtonItem.title = LocalizedString("remove", comment: "Remove")
        controller.shouldHideLostPhraseButton = false
        return controller
    }

}

extension RemoveSafeFlowCoordinator: RecoveryPhraseInputViewControllerDelegate {

    func recoveryPhraseInputViewControllerDidFinish(_ controller: RecoveryPhraseInputViewController) {
        removeWallet()
    }

    func recoveryPhraseInputViewController(_ controller: RecoveryPhraseInputViewController,
                                           didEnterPhrase phrase: String) {
        do {
            try ApplicationServiceRegistry.recoveryService.verifyRecoveryPhrase(phrase, id: walletID)
            controller.handleSuccess()
        } catch {
            controller.handleError(error)
        }
    }

    func recoveryPhraseInputViewControllerDidLooseRecovery(_ controller: RecoveryPhraseInputViewController) {
        ApplicationServiceRegistry.walletService.selectWallet(walletID)
        enter(flow: replacePhraseCoordinator) {
            MainFlowCoordinator.shared.switchToRootController()
            MainFlowCoordinator.shared.showTransactionList()
        }
    }

}
