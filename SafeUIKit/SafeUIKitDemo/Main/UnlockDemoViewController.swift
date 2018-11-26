//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeAppUI
import IdentityAccessApplication
import IdentityAccessImplementations

class UnlockDemoViewController: UITableViewController {

    var controller: UnlockViewController!
    let clock = SystemClockService()
    let mockAuthService = MockAuthenticationService()

    override func viewDidLoad() {
        super.viewDidLoad()

        ApplicationServiceRegistry.put(service: clock, for: Clock.self)
        ApplicationServiceRegistry.put(service: mockAuthService, for: AuthenticationApplicationService.self)

        mockAuthService.allowAuthentication()
//        mockAuthService.enableTouchIDSupport()
        mockAuthService.enableFaceIDSupport()
        mockAuthService.invalidateAuthentication()
//        mockAuthService.blockAuthentication()

        controller = .create { [unowned self] _ in
            self.controller.dismiss(animated: true, completion: nil)
        }
        controller.showsCancelButton = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            self.present(self.controller, animated: true, completion: nil)
        }
    }

}
