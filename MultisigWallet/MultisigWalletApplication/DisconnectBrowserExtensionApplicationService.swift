//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class DisconnectBrowserExtensionApplicationService: ReplaceBrowserExtensionApplicationService {

    public static func createDisconnectService() -> DisconnectBrowserExtensionApplicationService {
        let service = DisconnectBrowserExtensionApplicationService()
        service.domainService = DomainRegistry.disconnectExtensionService
        return service
    }

    open override func sign(transaction: RBETransactionID, withPhrase phrase: String) throws {
        DomainRegistry.disconnectExtensionService.update(transaction: TransactionID(transaction))
        try super.sign(transaction: transaction, withPhrase: phrase)
    }

}
