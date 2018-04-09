//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

class ApplicationServiceRegistry: AbstractRegistry {

    static var authenticationService: AuthenticationApplicationService {
        return service(for: AuthenticationApplicationService.self)
    }

    static var clock: Clock {
        return service(for: Clock.self)
    }

}
