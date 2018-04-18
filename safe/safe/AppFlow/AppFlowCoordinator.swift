//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

protocol AppFlowCoordinatorProtocol: class {

    func startViewController() -> UIViewController
    func appEntersForeground()

}

final class AppFlowCoordinator: AppFlowCoordinatorProtocol {

    let onboardingFlowCoordinator = OnboardingFlowCoordinator()
    private var lockedViewController: UIViewController!
    private var authenticationService: AuthenticationApplicationService {
        return ApplicationServiceRegistry.authenticationService
    }

    private var rootViewController: UIViewController? {
        get { return UIApplication.shared.keyWindow?.rootViewController }
        set { UIApplication.shared.keyWindow?.rootViewController = newValue }
    }

    private var shouldLockWhenAppActive: Bool {
        var isAuthenticated = false
        if let session = Authenticator.instance.session {
            isAuthenticated = authenticationService.isUserAuthenticated(session: session)
        }
        return authenticationService.isUserRegistered  && !isAuthenticated
    }

    func startViewController() -> UIViewController {
        lockedViewController = onboardingFlowCoordinator.startViewController()
        if authenticationService.isUserRegistered {
            return unlockController { [unowned self] in
                self.rootViewController = self.lockedViewController
            }
        }
        return lockedViewController
    }

    func unlockController(completion: @escaping () -> Void) -> UIViewController {
        return UnlockViewController.create(completion: completion)
    }

    func appEntersForeground() {
        guard let rootVC = self.rootViewController,
            !(rootVC is UnlockViewController) && shouldLockWhenAppActive else {
            return
        }
        lockedViewController = rootVC
        self.rootViewController = unlockController { [unowned self] in
            self.rootViewController = self.lockedViewController
        }
    }

}
