//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication
import MultisigWalletApplication

open class AppFlowCoordinator: FlowCoordinator {

    let onboardingFlowCoordinator = OnboardingFlowCoordinator()
    let mainFlowCoordinator = MainFlowCoordinator()
    private var lockedViewController: UIViewController!

    private var authenticationService: AuthenticationApplicationService {
        return IdentityAccessApplication.ApplicationServiceRegistry.authenticationService
    }
    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }
    private var applicationRootViewController: UIViewController? {
        get { return UIApplication.shared.keyWindow?.rootViewController }
        set { UIApplication.shared.keyWindow?.rootViewController = newValue }
    }

    private var shouldLockWhenAppActive: Bool {
        return authenticationService.isUserRegistered  && !authenticationService.isUserAuthenticated
    }

    public init() {
        super.init(rootViewController: TransparentNavigationController())
    }

    open override func setUp() {
        super.setUp()
        if walletService.hasReadyToUseWallet {
            enter(flow: mainFlowCoordinator)
        } else {
            enter(flow: onboardingFlowCoordinator) { [unowned self] in
                self.clearNavigationStack()
                self.enter(flow: self.mainFlowCoordinator)
            }
        }
        lockedViewController = rootViewController

        if authenticationService.isUserRegistered {
            applicationRootViewController = unlockController { [unowned self] in
                self.applicationRootViewController = self.lockedViewController
            }
        } else {
            applicationRootViewController = lockedViewController
        }
    }

    func unlockController(completion: @escaping () -> Void) -> UIViewController {
        return UnlockViewController.create(completion: completion)
    }

    open func appEntersForeground() {
        guard let rootVC = applicationRootViewController,
            !(rootVC is UnlockViewController) && shouldLockWhenAppActive else {
            return
        }
        lockedViewController = rootVC
        applicationRootViewController = unlockController { [unowned self] in
            self.applicationRootViewController = self.lockedViewController
        }
    }

    open func receive(message: [AnyHashable: Any]) {
        mainFlowCoordinator.receive(message: message)
    }
}
