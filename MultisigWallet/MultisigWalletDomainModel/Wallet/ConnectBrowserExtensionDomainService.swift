//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

open class ConnectBrowserExtensionDomainService: ReplaceBrowserExtensionDomainService {

    open override var isAvailable: Bool {
        guard let wallet = self.wallet else { return false }
        return wallet.owner(role: .browserExtension) == nil
    }

    override var transactionType: TransactionType { return .connectBrowserExtension }

    override func dummyTransactionData() -> Data {
        return contractProxy.addOwner(requiredWallet.address!, newThreshold: 2)
    }

    open override func newOwnerAddress(from transactionID: TransactionID) -> String? {
        let tx = self.transaction(transactionID)
        guard let data = tx.data, let arguments = contractProxy.decodeAddOwnerArguments(from: data) else { return nil }
        return arguments.new.value
    }

    override func validateOwners() throws {
        try assertNil(requiredWallet.owner(role: .browserExtension),
                      ReplaceBrowserExtensionDomainServiceError.browserExtensionAlreadyExists)
    }

    override func realTransactionData(with newAddress: String) -> Data? {
        return contractProxy.addOwner(Address(newAddress), newThreshold: 2)
    }

    override func processSuccess(with newOwner: String, in wallet: Wallet) throws {
        add(newOwner: newOwner, to: wallet)
        wallet.changeConfirmationCount(2)
        DomainRegistry.walletRepository.save(wallet)
    }

}
