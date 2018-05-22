//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class DomainRegistry: AbstractRegistry {

    public static var encryptionService: EncryptionDomainService {
        return service(for: EncryptionDomainService.self)
    }

}
