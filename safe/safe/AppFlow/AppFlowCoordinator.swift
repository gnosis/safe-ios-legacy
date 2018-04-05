//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

protocol AppFlowCoordinatorProtocol: class {

    func startViewController() -> UIViewController
    func appEntersForeground()

}

final class AppFlowCoordinator: AppFlowCoordinatorProtocol {

    let onboardingFlowCoordinator: OnboardingFlowCoordinator
    private var lockedViewController: UIViewController!
    private let identityService: IdentityApplicationService

    private var rootViewController: UIViewController? {
        get { return UIApplication.shared.keyWindow?.rootViewController }
        set { UIApplication.shared.keyWindow?.rootViewController = newValue }
    }

    private var shouldLockWhenAppActive: Bool { return identityService.hasAccess() }

    init(account: AccountProtocol = Account.shared) {
        identityService = IdentityApplicationService(account: account)
        onboardingFlowCoordinator = OnboardingFlowCoordinator(account: account)
    }

    func startViewController() -> UIViewController {
        lockedViewController = onboardingFlowCoordinator.startViewController()
        if identityService.hasPrimaryUser() {
            return unlockController { [unowned self] in
                self.rootViewController = self.lockedViewController
            }
        }
        return lockedViewController
    }

    func unlockController(completion: @escaping () -> Void) -> UIViewController {
        return UnlockViewController.create(account: identityService.account, completion: completion)
    }

    func appEntersForeground() {
        guard let rootVC = self.rootViewController, !(rootVC is UnlockViewController) && shouldLockWhenAppActive else {
            return
        }
        lockedViewController = rootVC
        self.rootViewController = unlockController { [unowned self] in
            self.rootViewController = self.lockedViewController
        }
    }

}
