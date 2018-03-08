//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class OnboardingFlowCoordinator {

    private let account: AccountProtocol
    let masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()
    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()

    init(account: AccountProtocol) {
        self.account = account
    }

    func startViewController() -> UIViewController {
        return account.hasMasterPassword ? setupSafeFlowCoordinator.startViewController() :
            masterPasswordFlowCoordinator.startViewController()
    }

}
