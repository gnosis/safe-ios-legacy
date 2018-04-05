//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class OnboardingFlowCoordinator: FlowCoordinator {

    private let account: AccountProtocol
    let masterPasswordFlowCoordinator: MasterPasswordFlowCoordinator
    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()

    init(account: AccountProtocol) {
        self.account = account
        masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()
        super.init()
        masterPasswordFlowCoordinator.completion = masterPasswordCompletion
    }

    private func masterPasswordCompletion() {
        let vc = setupSafeFlowCoordinator.startViewController(parent: rootVC)
        rootVC.setViewControllers([vc], animated: true)
    }

    override func flowStartController() -> UIViewController {
        return account.hasMasterPassword ? setupSafeFlowCoordinator.startViewController(parent: rootVC) :
            masterPasswordFlowCoordinator.startViewController(parent: rootVC)
    }

}
