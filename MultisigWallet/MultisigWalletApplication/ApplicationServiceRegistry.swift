//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class ApplicationServiceRegistry: AbstractRegistry {

    public static var walletService: WalletApplicationService {
        return service(for: WalletApplicationService.self)
    }

    public static var replacePhraseService: ReplaceRecoveryPhraseApplicationService {
        return service(for: ReplaceRecoveryPhraseApplicationService.self)
    }

    public static var replaceExtensionService: ReplaceBrowserExtensionApplicationService {
        return service(for: ReplaceBrowserExtensionApplicationService.self)
    }

    public static var connectTwoFAService: ConnectTwoFAApplicationService {
        return service(for: ConnectTwoFAApplicationService.self)
    }

    public static var disconnectTwoFAService: DisconnectTwoFAApplicationService {
        return service(for: DisconnectTwoFAApplicationService.self)
    }

    public static var contractUpgradeService: ContractUpgradeApplicationService {
        return service(for: ContractUpgradeApplicationService.self)
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

    public static var walletConnectService: WalletConnectApplicationService {
        return service(for: WalletConnectApplicationService.self)
    }

    static var eventRelay: EventRelay {
        return service(for: EventRelay.self)
    }

    public static var keycardService: KeycardApplicationService {
        return service(for: KeycardApplicationService.self)
    }

}
