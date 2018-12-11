//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class ApplicationServiceRegistry: AbstractRegistry {

    public static var walletService: WalletApplicationService {
        return service(for: WalletApplicationService.self)
    }

    public static var recoveryService: RecoveryApplicationService {
        return service(for: RecoveryApplicationService.self)
    }

    public static var settingsService: WalletSettingsApplicationService {
        return service(for: WalletSettingsApplicationService.self)
    }

    public static var logger: Logger {
        return service(for: Logger.self)
    }

    public static var ethereumService: EthereumApplicationService {
        return service(for: EthereumApplicationService.self)
    }

    static var eventRelay: EventRelay {
        return service(for: EventRelay.self)
    }

}
