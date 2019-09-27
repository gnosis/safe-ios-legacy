//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

final class RemoveSafeFlowCoordinator: FlowCoordinator {

    var safeAddress: String!

    override func setUp() {
        super.setUp()
        push(removeSafeIntro())
    }

    private func removeSafeIntro() -> UIViewController {
        return RemoveSafeIntroViewController.create(address: safeAddress) { [unowned self] in
            self.push(self.removeSafeEnterSeed())
        }
    }

    private func removeSafeEnterSeed() -> UIViewController {
        let controller = RecoveryPhraseInputViewController.create(delegate: self)
        controller.title = RemoveSafeIntroViewController.Strings.title
        controller.screenTrackingEvent = SafesTrackingEvent.removeSafeEnterSeed
        controller.nextButtonItem.title = LocalizedString("remove", comment: "Remove")
        return controller
    }

}

extension RemoveSafeFlowCoordinator: RecoveryPhraseInputViewControllerDelegate {

    func recoveryPhraseInputViewControllerDidFinish() {
        ApplicationServiceRegistry.walletService.removeWallet(address: safeAddress)
        exitFlow()
    }

    func recoveryPhraseInputViewController(_ controller: RecoveryPhraseInputViewController,
                                           didEnterPhrase phrase: String) {
        let result = ApplicationServiceRegistry.recoveryService
            .verifyRecoveryPhrase(phrase, address: safeAddress)
        switch result {
        case .failure(let error):
            controller.handleError(error)
        case .success(_):
            controller.handleSuccess()
        }
    }

}
