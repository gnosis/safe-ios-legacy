//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

class ApplicationServiceRegistry: AbstractRegistry {

    class func authenticationService() -> AuthenticationApplicationService {
        return service(for: AuthenticationApplicationService.self)
    }

}
