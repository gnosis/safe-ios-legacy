//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class NewSafeFlowCoordinator: FlowCoordinator {

    var paperWalletFlowCoordinator: PaperWalletFlowCoordinator!

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }
    private(set) lazy var draftSafe = try? identityService.getOrCreateDraftSafe()

    override init(rootViewController: UIViewController? = nil) {
        super.init(rootViewController: rootViewController)
        paperWalletFlowCoordinator = PaperWalletFlowCoordinator(draftSafe: draftSafe)
    }

    override func setUp() {
        super.setUp()
        push(NewSafeViewController.create(delegate: self))
    }

    func enterAndComeBack(from coordinator: FlowCoordinator, completion: @escaping () -> Void) {
        let startVC = navigationController.topViewController
        enter(flow: coordinator) {
            completion()
            if let startVC = startVC {
                self.pop(to: startVC)
            }
        }
    }

}

extension NewSafeFlowCoordinator: NewSafeDelegate {

    func didSelectPaperWalletSetup() {
        enterAndComeBack(from: paperWalletFlowCoordinator) {
// TODO: this should be done in controller
            self.identityService.confirmPaperWallet(draftSafe: self.draftSafe!)
        }
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
