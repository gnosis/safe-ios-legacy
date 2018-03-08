//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class AppFlowCoordinator {

    private let account: AccountProtocol
    let onboardingFlowCoordinator: OnboardingFlowCoordinator

    init(account: AccountProtocol = Account.shared) {
        self.account = account
        onboardingFlowCoordinator = OnboardingFlowCoordinator(account: account)
    }

    func startViewController() -> UIViewController {
        // Check ACCOUNT SESSION        
        return account.hasMasterPassword ? unlockController() : onboardingFlowCoordinator.startViewController()
    }

    func unlockController() -> UIViewController {
        return UnlockViewController()
    }

}
