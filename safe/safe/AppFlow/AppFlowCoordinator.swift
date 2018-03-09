//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class AppFlowCoordinator {

    private let account: AccountProtocol
    let onboardingFlowCoordinator: OnboardingFlowCoordinator
    private var lockedViewController: UIViewController!

    init(account: AccountProtocol = Account.shared) {
        self.account = account
        onboardingFlowCoordinator = OnboardingFlowCoordinator(account: account)
    }

    func startViewController() -> UIViewController {
        lockedViewController = onboardingFlowCoordinator.startViewController()
        if account.hasMasterPassword {
            return unlockController { [unowned self] in
                UIApplication.shared.keyWindow?.rootViewController = self.lockedViewController
            }
        }
        return lockedViewController
    }

    func unlockController(completion: @escaping () -> Void) -> UIViewController {
        return UnlockViewController.create(account: account, completion: completion)
    }

}
