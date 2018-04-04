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
        print("Master Password Completion")
    }

    override func flowStartController() -> UIViewController {
        return account.hasMasterPassword ? setupSafeFlowCoordinator.startViewController() :
            masterPasswordFlowCoordinator.startViewController(parent: rootVC)
    }

}
