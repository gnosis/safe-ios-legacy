//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class OnboardingFlowCoordinator {

    private let identityService: IdentityApplicationService
    let masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()
    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()

    init(account: AccountProtocol) {
        identityService = IdentityApplicationService(account: account)
    }

    func startViewController() -> UIViewController {
        return identityService.hasRegisteredUser() ? setupSafeFlowCoordinator.startViewController() :
            masterPasswordFlowCoordinator.startViewController()
    }

}
