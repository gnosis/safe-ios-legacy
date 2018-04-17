//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class DomainRegistry: AbstractRegistry {

    public static var keyValueStore: KeyValueStore {
        return service(for: KeyValueStore.self)
    }

    public static var secureStore: SecureStore {
        return service(for: SecureStore.self)
    }

    public static var biometricAuthenticationService: BiometricAuthenticationService {
        return service(for: BiometricAuthenticationService.self)
    }

    public static var logger: Logger {
        return service(for: Logger.self)
    }

    public static var encryptionService: EncryptionServiceProtocol {
        return service(for: EncryptionServiceProtocol.self)
    }

    public static var userRepository: UserRepository {
        return service(for: UserRepository.self)
    }

    public static var identityService: IdentityService {
        return service(for: IdentityService.self)
    }

    public static var gatekeeperRepository: GatekeeperRepository {
        return service(for: GatekeeperRepository.self)
    }
}
