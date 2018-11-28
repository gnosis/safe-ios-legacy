//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeAppUI
import IdentityAccessApplication
import IdentityAccessImplementations

class UnlockDemoViewController: BaseDemoViewController {

    override var demoController: UIViewController { return controller }

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

}
