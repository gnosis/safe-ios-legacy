//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class OnboardingFlowCoordinator {

    private let authenticationService: AuthenticationApplicationService
    let masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()
    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()

    init(account: AccountProtocol) {
        authenticationService = AuthenticationApplicationService(account: account)
    }

    func startViewController() -> UIViewController {
        return authenticationService.isUserRegistered() ? setupSafeFlowCoordinator.startViewController() :
            masterPasswordFlowCoordinator.startViewController()
    }

}
