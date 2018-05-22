//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class ApplicationServiceRegistry: AbstractRegistry {

    public static var walletService: WalletApplicationService {
        return service(for: WalletApplicationService.self)
    }

    public static var logger: Logger {
        return service(for: Logger.self)
    }

}
