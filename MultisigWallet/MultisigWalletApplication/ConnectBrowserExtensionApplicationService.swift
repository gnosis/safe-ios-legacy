//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class ConnectBrowserExtensionApplicationService: OwnerModificationApplicationService {

    public static func create() -> ConnectBrowserExtensionApplicationService {
        let service = ConnectBrowserExtensionApplicationService()
        service.domainService = DomainRegistry.connectExtensionService
        return service
    }

}
