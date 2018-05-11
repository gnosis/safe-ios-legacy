//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication
import MultisigWalletApplication

public protocol AppFlowCoordinatorProtocol: class {

    func startViewController() -> UIViewController
    func appEntersForeground()

}

public final class AppFlowCoordinator: AppFlowCoordinatorProtocol {

    let onboardingFlowCoordinator = OnboardingFlowCoordinator()
    private var lockedViewController: UIViewController!
    private var authenticationService: AuthenticationApplicationService {
        return IdentityAccessApplication.ApplicationServiceRegistry.authenticationService
    }
    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }
    private var rootViewController: UIViewController? {
        get { return UIApplication.shared.keyWindow?.rootViewController }
        set { UIApplication.shared.keyWindow?.rootViewController = newValue }
    }

    private var shouldLockWhenAppActive: Bool {
        return authenticationService.isUserRegistered  && !authenticationService.isUserAuthenticated
    }

    public init() {}

    public func startViewController() -> UIViewController {
        lockedViewController = walletService.hasReadyToUseWallet ? mainController() :
            onboardingFlowCoordinator.startViewController()
        if authenticationService.isUserRegistered {
            return unlockController { [unowned self] in
                self.rootViewController = self.lockedViewController
            }
        }
        return lockedViewController
    }

    private func mainController() -> UIViewController {
        return MainViewController.create()
    }

    func unlockController(completion: @escaping () -> Void) -> UIViewController {
        return UnlockViewController.create(completion: completion)
    }

    public func appEntersForeground() {
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
