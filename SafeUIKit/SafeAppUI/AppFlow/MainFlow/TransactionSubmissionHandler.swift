//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessApplication

class TransactionSubmissionHandler {

    func submitTransaction(from flowCoordinator: FlowCoordinator, completion: @escaping (Bool) -> Void) {
        if IdentityAccessApplication.ApplicationServiceRegistry.authenticationService.isUserAuthenticated {
            completion(true)
        } else {
            let unlockVC = UnlockViewController.create { [unowned flowCoordinator] success in
                flowCoordinator.dismissModal()
                completion(success)
            }
            unlockVC.showsCancelButton = true
            flowCoordinator.presentModally(unlockVC)
        }
    }

}
