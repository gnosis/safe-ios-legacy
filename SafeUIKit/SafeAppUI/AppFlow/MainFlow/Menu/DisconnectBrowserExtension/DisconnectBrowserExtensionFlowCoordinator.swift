//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class DisconnectBrowserExtensionFlowCoordinator: FlowCoordinator {

    weak var introVC: RBEIntroViewController!
    var transactionID: RBETransactionID!
    fileprivate var applicationService: DisconnectBrowserExtensionApplicationService {
        return ApplicationServiceRegistry.disconnectExtensionService
    }

    override func setUp() {
        super.setUp()
        let vc = RBEIntroViewController.create()
        vc.starter = ApplicationServiceRegistry.disconnectExtensionService
        vc.delegate = self
        vc.setContent(.disconnectExtension)
        introVC = vc
        push(vc)
    }

}

extension IntroContentView.Content {

    static let disconnectExtension =
        IntroContentView.Content(header: LocalizedString("disconnect_extension.intro.header", comment: "Header label"),
                                 body: LocalizedString("disconnect_extension.intro.body", comment: "Body text"),
                                 icon: Asset.ConnectBrowserExtension.connectIntroIcon.image)

}

extension DisconnectBrowserExtensionFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        self.transactionID = introVC!.transactionID
        let controller = RecoveryPhraseInputViewController.create(delegate: self)
        push(controller)
    }

}

extension DisconnectBrowserExtensionFlowCoordinator: RecoveryPhraseInputViewControllerDelegate {

    func recoveryPhraseInputViewController(_ controller: RecoveryPhraseInputViewController,
                                           didEnterPhrase phrase: String) {
        do {
            try applicationService.sign(transaction: transactionID, withPhrase: phrase)
            controller.handleSuccess()
        } catch {
            controller.handleError(error)
        }
    }

    func recoveryPhraseInputViewControllerDidFinish() {
        let vc = RBEReviewTransactionViewController(transactionID: transactionID, delegate: self)
        vc.titleString = LocalizedString("disconnect_extension.review.title", comment: "Title for the header")
        vc.detailString = LocalizedString("disconnect_extension.review.detail", comment: "Detail for the header")
        push(vc)
    }

}

extension DisconnectBrowserExtensionFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func wantsToSubmitTransaction(_ completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func didFinishReview() {
        applicationService.startMonitoring(transaction: transactionID)
        exitFlow()
    }

}
