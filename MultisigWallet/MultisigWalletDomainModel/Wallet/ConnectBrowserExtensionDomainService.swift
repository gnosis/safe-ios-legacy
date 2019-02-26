//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

open class ConnectBrowserExtensionDomainService: ReplaceBrowserExtensionDomainService {

    open override var isAvailable: Bool {
        return !super.isAvailable
    }

    override var transactionType: TransactionType { return .connectBrowserExtension }

    override func dummySwapData() -> Data {
        return contractProxy.addOwner(requiredWallet.address!, newThreshold: 2)
    }

    override func validateOwners() throws {
        try assertNil(requiredWallet.owner(role: .browserExtension),
                      ReplaceBrowserExtensionDomainServiceError.browserExtensionAlreadyExists)
    }

    override func realTransactionData(with newAddress: String) -> Data? {
        return contractProxy.addOwner(Address(newAddress), newThreshold: 2)
    }

}
