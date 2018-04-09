//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

class DomainRegistry: AbstractRegistry {

    static var keyValueStore: KeyValueStore {
        return service(for: KeyValueStore.self)
    }

    static var secureStore: SecureStore {
        return service(for: SecureStore.self)
    }

    static var biometricAuthenticationService: BiometricAuthenticationService {
        return service(for: BiometricAuthenticationService.self)
    }

    static var clock: Clock {
        return service(for: Clock.self)
    }

    static var logger: Logger {
        return service(for: Logger.self)
    }

}
