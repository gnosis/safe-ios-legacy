//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class NewSafeFlowCoordinator: FlowCoordinator {

    var paperWalletFlowCoordinator: PaperWalletFlowCoordinator!
    var pairWithExtensionFlowCoordinator: PairWithBrowserExtensionFlowCoordinator!

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }
    private(set) lazy var draftSafe = try? identityService.getOrCreateDraftSafe()

    override init(rootViewController: UIViewController? = nil) {
        super.init(rootViewController: rootViewController)
        paperWalletFlowCoordinator = PaperWalletFlowCoordinator(draftSafe: draftSafe)
    }

    override func setUp() {
        super.setUp()
        let controller = NewSafeViewController.create(draftSafe: draftSafe, delegate: self)
        pushController(controller)
    }

}

extension NewSafeFlowCoordinator: NewSafeDelegate {

    func didSelectPaperWalletSetup() {
        transitionThenPopToStart(with: paperWalletFlowCoordinator) {
            // TODO: this should be done in controller
            self.identityService.confirmPaperWallet(draftSafe: self.draftSafe!)
        }
    }

    func didSelectBrowserExtensionSetup() {
        let address = draftSafe?.browserExtensionAddressString
        pairWithExtensionFlowCoordinator = PairWithBrowserExtensionFlowCoordinator(address: address)
        transitionThenPopToStart(with: pairWithExtensionFlowCoordinator) {
            // TODO: this should be done in controller because coordinator only handles controller transitions
            if let extensionAddress = self.pairWithExtensionFlowCoordinator.extensionAddress {
                self.identityService.confirmBrowserExtension(draftSafe: self.draftSafe!, address: extensionAddress)
            }
        }
    }

    func transitionThenPopToStart(with coordinator: FlowCoordinator, completion: @escaping () -> Void) {
        let startVC = navigationController.topViewController
        transition(to: coordinator) {
            completion()
            if let startVC = startVC {
                self.pop(to: startVC)
            }
        }
    }

    func didSelectNext() {
        pushController(PendingSafeViewController())
    }

}
