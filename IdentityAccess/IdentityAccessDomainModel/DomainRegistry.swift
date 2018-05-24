//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class DomainRegistry: AbstractRegistry {

    public static var biometricAuthenticationService: BiometricAuthenticationService {
        return service(for: BiometricAuthenticationService.self)
    }

    public static var encryptionService: EncryptionService {
        return service(for: EncryptionService.self)
    }

    public static var userRepository: SingleUserRepository {
        return service(for: SingleUserRepository.self)
    }

    public static var identityService: IdentityService {
        return service(for: IdentityService.self)
    }

    public static var gatekeeperRepository: SingleGatekeeperRepository {
        return service(for: SingleGatekeeperRepository.self)
    }
}
